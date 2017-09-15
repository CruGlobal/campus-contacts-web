require 'contact_methods'
include WiserTimezone::WiserTimezoneHelper
class ApplicationController < ActionController::Base
  extend DelegatePresenter::ApplicationController
  include ContactMethods

  force_ssl if: :ssl_configured?, except: [:lb]
  before_action :check_valid_subdomain
  before_action :authenticate_user!, except: [:facebook_logout, :redirect_admin]
  before_action :clear_advanced_search
  before_action :set_login_cookie
  before_action :check_su
  before_action :set_locale
  before_action :check_url, except: [:facebook_logout]
  before_action :export_i18n_messages
  before_action :set_newrelic_params
  before_action :ensure_timezone
  before_action :check_signature, except: [:set_timezone]
  before_action :check_all_signatures, except: [:set_timezone]
  # around_filter :set_user_time_zone

  rescue_from CanCan::AccessDenied, with: :access_denied
  protect_from_forgery

  def ssl_configured?
    !Rails.env.development? && !Rails.env.test? && !available_locales.include?(request.subdomains.first)
  end

  def clear_advanced_search
    session[:filters] = nil
  end

  def redirect_admin
    api_remote = [0, 80].include?(ENV['API_PORT'])
    api_port = api_remote ? nil : ENV['API_PORT']
    api_protocol = api_remote ? 'https' : 'http'
    api_url = URI::HTTP.build(host: ENV['API_HOST'],
                              path: request.original_fullpath,
                              port: api_port,
                              protocol: api_protocol).to_s
    redirect_to api_url
  end

  # def set_user_time_zone
  #   old_time_zone = Time.zone
  #   if user_signed_in? && current_user.settings[:time_zone]
  #     Time.zone = current_user.settings[:time_zone]
  #   else
  #     if cookies[:timezone].present?
  #       Time.zone = ActiveSupport::TimeZone[-cookies[:timezone].to_i.minutes]
  #       current_user.update_attribute(:time_zone, Time.zone.name) if user_signed_in?
  #     end
  #   end
  #   yield
  # ensure
  #   Time.zone = old_time_zone
  # end

  def facebook_logout
    redirect_url = params[:next] ? params[:next] : root_url
    if session[:fb_token]
      split_token = session[:fb_token].split('|')
      fb_api_key = split_token[0]
      fb_session_key = split_token[1]
      session[:fb_token] = nil
      if mhub?
        # redirect_to "http://www.facebook.com/logout.php?api_key=#{fb_api_key}&session_key=#{fb_session_key}&confirm=1&next=#{redirect_url}"
        redirect_to redirect_url # "http://m.facebook.com/logout.php?confirm=1&next=#{redirect_url}"
      else
        redirect_to redirect_url
      end
    else
      redirect_to redirect_url
    end
    sign_out
  end

  def manage_wild_card(term)
    term = '%' + term[0..term.size - 1] + '%' unless term.last == '*' || term.first == '*'
    term = '%' + term[1..term.size] if term.first == '*'
    term = term[0..term.size - 2] + '%' if term.last == '*'
    term
  end

  def convert_hash_to_url(hash)
    return "/allcontacts?#{hash.reject { |k, _v| %w(action controller).include?(k) }.to_param}" if hash.present?
  end

  def search?
    params[:advanced_search].present? || params[:do_search].present? || params[:search].present?
  end

  def check_signature
    return false unless user_signed_in?
    return false unless current_organization.present?
    return false unless current_organization.is_power_to_change?
    return false unless current_person.is_admin_for_org?(current_organization)
    if !current_person.has_org_signature_of_kind?(current_organization, Signature::SIGNATURE_CODE_OF_CONDUCT)
      redirect_to code_of_conduct_signatures_path
    elsif !current_person.has_org_signature_of_kind?(current_organization, Signature::SIGNATURE_STATEMENT_OF_FAITH)
      redirect_to statement_of_faith_signatures_path
    end
  end

  def check_all_signatures
    return false unless user_signed_in?
    return false unless current_organization.present?
    return false unless current_organization.is_power_to_change?
    return false unless current_person.is_admin_for_org?(current_organization)
    return false if current_person.accepted_all_signatures?(current_organization)
    redirect_to root_path, notice: I18n.t('signatures.declined_a_signature')
  end

  protected

  def set_newrelic_params
    if user_signed_in?
      NewRelic::Agent.add_custom_parameters(user_id: current_user.id, username: current_user.username, person_id: current_person.try(:id), name: current_person.to_s)
    end
  end

  def set_login_cookie
    if user_signed_in?
      cookies['logged_in'] = true unless cookies['logged_in']
    else
      cookies['logged_in'] = nil if cookies['logged_in']
    end
  end

  def raise_or_hoptoad(e, options = {})
    if Rails.env.production?
      Rollbar.error(e, options)
    else
      fail e
    end
  end
  helper_method :raise_or_hoptoad

  def check_url
    render_404 if mhub?
  end

  def render_404(nologin = false)
    if cookies[:keyword] && SmsKeyword.where(keyword: cookies[:keyword]).first
      url = "/c/#{cookies[:keyword]}"
      url += '?nologin=true' if nologin
      redirect_to url
    elsif cookies[:survey_id] && Survey.where(id: cookies[:survey_id]).first
      url = "/survey_responses/new?survey_id=#{cookies[:survey_id]}"
      url += '&nologin=true' if nologin
      redirect_to url
    else
      render file: Rails.root.join(mhub? ? 'public/404_mhub.html' : 'public/404.html'), layout: false, status: 404
    end
    false
  end

  def mhub?
    @mhub = request.host.include?(ENV['PUBLIC_HOST'] || 'mhub') if @mhub.nil?
    @mhub
  end
  helper_method :mhub?

  def self.application_name
    'MH'
  end

  def check_su
    # Act as another user
    if params[:user_id] && params[:su] && current_user.developer?
      switch_to_user(params[:user_id], true)
      redirect = true
    elsif params[:exit] && session['old_user_id']
      switch_to_user(session['old_user_id'])
      redirect = true
    end
    redirect_to url_for(params.except(:user_id, :su, :exit)) and return false if redirect
  end

  def switch_to_user(user_id, save_old = false)
    session['old_user_id'] = save_old ? current_user.id : nil
    sign_in(:user, User.find(user_id))
    # session['fb_token'] = nil
    # session['current_organization_id'] = nil
    # session['warden.user.user.key'] = ["User", [user_id.to_i], nil]
    # session['wizard'] = nil
  end

  def authenticate_admin!
    redirect_to root_path unless is_admin?
  end

  def authenticate_super_admin!
    redirect_to root_path unless current_user.super_admin.present?
  end

  def facebook_token
    @facebook_token ||= (params[:facebook_token] || facebook_token_from_header)
  end

  # grabs facebook token from header if one is present
  def facebook_token_from_header
    auth_header = request.env['HTTP_AUTHORIZATION'] || ''
    match = auth_header.match(/^Facebook\s(.*)/)
    return match[1] if match.present?
    false
  end

  def current_user
    # check for access token, then do it the devise way
    case
    when current_access_token
      token = Rack::OAuth2::Server.get_access_token(current_access_token)
      if token.identity
        @current_user ||= User.find(token.identity)
      else
        organization = token.client.organization || Organization.find(params[:org_id])
        session[:current_organization_id] ||= organization.id
        if params[:user_id]
          @current_user ||= token.client.organization.admins.where(user_id: params[:user_id]).first.user
        else
          @current_user ||= token.client.organization.admins.where('user_id is not null').first.user
        end
      end
      @current_user
    when facebook_token
      @current_user = Authentication.user_from_mobile_facebook_token(facebook_token)
    else
      super # devise user
    end
  end

  def current_access_token
    @access_token ||= params['access_token'] || request.env['oauth.access_token']
  end
  helper_method :current_access_token

  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == '1'
    else
      request.user_agent =~ /Mobile|webOS|Android/
    end
  end
  helper_method :mobile_device?

  def prepare_for_mobile
    session[:mobile_param] = params[:mobile] if params[:mobile]
    request.format = :mobile if mobile_device?
  end

  def current_person
    @current_person ||= current_user.person if current_user
    @current_person ||= Person.where(id: session[:person_id]).first if session[:person_id]
    @current_person
  end
  helper_method :current_person

  def get_guid_from_ticket(ticket)
    ticket.response.to_s.match(/ssoGuid>([A-Z0-9\-]*)/)[1]
  rescue => e
    raise e.message + ' -- ' + ticket.response.inspect
  end

  def available_locales
    %w(en ru es fr zh bs de ca qb qc)
  end

  def check_valid_subdomain
    return if request.subdomains.first.blank?
    session[:locale] = request.subdomains.first if available_locales.include?(request.subdomains.first)
    unless %w(local stage aws lwi www pact-hr-production-502563678).include?(request.subdomains.first)
      scheme = ssl_configured? ? 'https://' : 'http://'
      url = scheme + ENV['APP_DOMAIN'] + request.path
      url += "?locale=#{session[:locale]}" if session[:locale].present?
      redirect_to url and return false
    end
  end

  def set_locale
    session[:locale] = params[:locale] if params[:locale]
    session[:locale] = 'qb' if session[:locale] == 'qc'
    current_user.update(language: session[:locale]) if current_user && session[:locale]
    I18n.locale = current_user&.user_language || session[:locale] || 'en'
  end

  def export_i18n_messages
    # generates the Javascript translation file
    SimplesIdeias::I18n.export! if Rails.env.development?
  end

  def current_organization(person = nil)
    person ||= current_person if user_signed_in?
    return nil unless person

    if params[:temp_current_organization_id].present?
      return @temp_current_organization if @temp_current_organization.present?
      if current_person.org_ids.key?(params[:temp_current_organization_id].to_i)
        return @temp_current_organization = Organization.find(params[:temp_current_organization_id])
      end
    end

    @current_organizations ||= {}
    return @current_organizations[person] if @current_organizations.key?(person)
    # Set current org based on the session, particularly uses in set_current org feature
    if session[:current_organization_id]
      org = person.organization_from_id(session[:current_organization_id])
      # org = nil unless org && (person.organizations.include?(org) || person.organizations.include?(org.parent))
    end

    # Set current org if there's primary_organization_id in current_user's 'settings' as a default org
    if current_user && !org
      if default_organization_id = current_user.primary_organization_id
        org = person.organization_from_id(default_organization_id)
        session[:current_organization_id] = default_organization_id
      end
    end

    unless org
      if org = person.primary_organization
        # If they're a contact at their primary org (shouldn't happen), look for another org where they have a different permission
        if !person.org_ids[org.id] || (person.org_ids[org.id]['permissions'] & Permission.user_ids).blank?
          person.primary_organization = person.organizations.first
        end
        session[:current_organization_id] = person.primary_organization.id
      else
        session[:current_organization_id] = nil
      end
    end
    @current_organizations[person] = org
  end
  helper_method :current_organization

  def authenticate_user!
    flash[:facebook_logout] = flash[:facebook_logout]
    super
  end

  # Fake login
  # def authenticate_user!
  #   true
  # end
  #
  # def user_signed_in?
  #   true
  # end
  #
  # def current_user
  #   @current_user ||= User.find(42655)
  #   session[:user_id] = @current_user.id
  #   @current_user
  # end

  def unassigned_people(organization)
    @unassigned_people ||= organization.unassigned_people
  end
  helper_method :unassigned_people

  def user_root_path
    if mhub?
      if cookies[:keyword] && SmsKeyword.where(keyword: cookies[:keyword]).first
        url = "/c/#{cookies[:keyword]}"
      elsif cookies[:survey_id] && Survey.where(id: cookies[:survey_id]).first
        url = "/survey_responses/new?survey_id=#{cookies[:survey_id]}"
      else
        url = '/users/sign_in'
      end
      return url
    else
      return '/'
    end
  end
  helper_method :user_root_path

  def wizard_path
    step = current_user.next_wizard_step(current_organization)
    '/wizard?step=' + step if step
  end
  helper_method :wizard_path

  def create_person(person_params)
    Person.new_from_params(person_params)
  end

  def ensure_current_org
    redirect_to '/wizard' and return false unless current_organization
  end

  def access_denied
    render 'application/access_denied'
    false
  end

  def is_leader?
    current_user.has_permission?(Permission::USER_ID, current_organization) || is_admin?
  end

  def is_admin?
    current_user.has_permission?(Permission::ADMIN_ID, current_organization)
  end
  helper_method :is_admin?

  def get_survey
    if params[:keyword]
      @keyword ||= SmsKeyword.where(keyword: params[:keyword]).first
      @survey = @keyword ? @keyword.survey : Survey.find(params[:keyword])
    elsif params[:received_sms_id]
      sms_id = Base62.decode(params[:received_sms_id])
      @sms = SmsSession.where(id: sms_id).first
      if @sms
        @keyword ||= @sms.sms_keyword
        @survey = @keyword.survey if @keyword
      end
    elsif params[:survey_id] || params[:id] || cookies[:survey_id]
      @survey = Survey.where(id: params[:survey_id] || params[:id] || cookies[:survey_id]).first
    end
    if params[:keyword] || params[:received_sms_id] || params[:survey_id] || params[:id]
      unless @survey
        render_404
        return false
      end
    end
  end

  def set_keyword_cookie
    get_survey
    cookies[:keyword] = @keyword.keyword if @keyword
    if @survey
      cookies[:survey_id] = @survey.id
    else
      return false
    end
  end

  def groups_for_assign
    @groups_for_assign = current_organization.groups
  end

  def labels_for_assign
    @labels_for_assign = current_organization.label_set
  end

  def permissions_for_assign
    current_user_permissions = current_person
                               .organizational_permissions
                               .where(organization_id: current_organization.self_and_parents.collect(&:id))
                               .collect { |r| Permission.where(id: r.permission_id).first }.compact

    if current_user_permissions.include?(Permission.admin)
      @permissions_for_assign = current_organization.permissions
    else
      @permissions_for_assign = current_organization.permissions.select { |permission| permission != Permission.admin }
    end
  end

  def current_user_super_admin?
    if SuperAdmin.all.collect(&:user_id).include? current_user.id
      true
    else
      false
    end
  end
  helper_method :current_user_super_admin?

  def format_date_for_search(input_date)
    if input_date =~ /^([1-9]|0[1-9]|1[012])\/([1-9]|0[1-9]|[12][0-9]|3[01])\/(19|2\d)\d\d$/
      begin
        get_date = input_date.split('/')
        new_date = Date.parse("#{get_date[2]}-#{get_date[0]}-#{get_date[1]}").strftime('%Y-%m-%d')
      rescue
      end
    end
    new_date.present? ? new_date : input_date
  end

  def force_client_update
    platform = params[:platform] if params[:platform].present?
    version = params[:app] if params[:app].present?

    if platform && version
      version = version.to_i
      if platform == 'android'
        if version <= 6 # mh 1.x
          render json: { error: { message: 'Your MissionHub app requires an update. Please check for updates in your app store now.', code: 'client_update_required', title: 'Update Required' } },
                 status: :not_acceptable,
                 callback: params[:callback]
        elsif version <= 125 # mh 2.0.x-2.4.x-snapshot
          render json: { errors: ['Your MissionHub app requires an update. Please check for updates in your app store now.'], code: 'client_update_required' },
                 status: :not_acceptable,
                 callback: params[:callback]
          return false
        end
      end
    end
  end

  def initialize_surveys_and_questions
    @organization = current_organization
    @surveys = @organization.surveys
    @all_questions = @organization.questions
    excepted_predefined_fields = %w(first_name last_name gender phone_number)
    @predefined_survey = Survey.find(ENV.fetch('PREDEFINED_SURVEY'))
    @predefined_questions = current_organization.predefined_survey_questions.where('attribute_name NOT IN (?)', excepted_predefined_fields)
    @questions = (@all_questions.where('survey_elements.hidden' => false) + @predefined_questions.where(id: current_organization.settings[:visible_predefined_questions])).uniq
  end
  helper_method :initialize_surveys_and_questions

  def branded?
    !ENV['UNBRANDED']
  end
  helper_method :branded?

  def check_new_current_organization
    if params[:organization_id].present? && current_person.org_ids.key?(params[:organization_id].to_i)
      session[:current_organization_id] = params[:organization_id].to_i
      @current_organizations[current_person] = Organization.find(params[:organization_id])
    end
  end
end
