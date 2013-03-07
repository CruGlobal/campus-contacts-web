require 'contact_methods'
class ApplicationController < ActionController::Base
  extend DelegatePresenter::ApplicationController
  include ContactMethods
  before_filter :authenticate_user!, :except => [:facebook_logout]
  before_filter :set_login_cookie
  before_filter :check_su
  before_filter :check_valid_subdomain
  before_filter :set_locale
  before_filter :check_url, except: :facebook_logout
  before_filter :export_i18n_messages
  before_filter :set_newrelic_params
  around_filter :set_user_time_zone

  rescue_from CanCan::AccessDenied, with: :access_denied
  protect_from_forgery

  def set_user_time_zone
    old_time_zone = Time.zone
    if user_signed_in? && current_user.settings[:time_zone]
      Time.zone = current_user.settings[:time_zone]
    else
      if cookies[:timezone].present?
        Time.zone = ActiveSupport::TimeZone[-cookies[:timezone].to_i.minutes]
        current_user.update_attribute(:time_zone, Time.zone.name) if user_signed_in?
      end
    end
    yield
  ensure
    Time.zone = old_time_zone
  end

  def facebook_logout
    redirect_url = params[:next] ? params[:next] : root_url
    if session[:fb_token]
      split_token = session[:fb_token].split("|")
      fb_api_key = split_token[0]
      fb_session_key = split_token[1]
      session[:fb_token] = nil
      if mhub?
        # redirect_to "http://www.facebook.com/logout.php?api_key=#{fb_api_key}&session_key=#{fb_session_key}&confirm=1&next=#{redirect_url}"
        redirect_to redirect_url #"http://m.facebook.com/logout.php?confirm=1&next=#{redirect_url}"
      else
        redirect_to redirect_url
      end
    else
      redirect_to redirect_url
    end
    sign_out
  end

  protected

  def set_newrelic_params
    if user_signed_in?
      NewRelic::Agent.add_custom_parameters(:user_id => current_user.id, :username => current_user.username, :person_id => current_person.try(:id), :name => current_person.to_s)
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
      Airbrake.notify(e, options)
    else
      raise e
    end
  end
  helper_method :raise_or_hoptoad

  def check_url
    render_404 if mhub?
  end

  def render_404(nologin = false)
    if cookies[:keyword] && SmsKeyword.find_by_keyword(cookies[:keyword])
      url = "/c/#{cookies[:keyword]}"
      url += '?nologin=true' if nologin
      redirect_to url
    elsif cookies[:survey_id] && Survey.find_by_id(cookies[:survey_id])
      url = "/survey_responses/new?survey_id=#{cookies[:survey_id]}"
      url += '&nologin=true' if nologin
      redirect_to url
    else
      render :file => Rails.root.join(mhub? ? 'public/404_mhub.html' : 'public/404.html'), :layout => false, :status => 404
    end
    return false
  end

  def mhub?
    @mhub = request.host.include?(APP_CONFIG['public_host'] || 'mhub') if @mhub.nil?
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
    redirect_to params.except(:user_id, :su, :exit) and return false if redirect
  end

  def switch_to_user(user_id, save_old = false)
    session['old_user_id'] = save_old ? current_user.id : nil
    sign_in(:user, User.find(user_id))
    #session['fb_token'] = nil
    #session['current_organization_id'] = nil
    #session['warden.user.user.key'] = ["User", [user_id.to_i], nil]
    #session['wizard'] = nil
  end

  def current_user
    # check for access token, then do it the devise way
    if current_access_token
      token = Rack::OAuth2::Server.get_access_token(current_access_token)
      if token.identity
        @current_user ||= User.find(token.identity)
      else
        organization = token.client.organization || Organization.find(params[:org_id])
        session[:current_organization_id] ||= organization.id
        if params[:user_id]
          @current_user ||= token.client.organization.admins.where(:user_id => params[:user_id]).first.user
        else
          @current_user ||= token.client.organization.admins.where("user_id is not null").first.user
        end
      end
      @current_user
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
      session[:mobile_param] == "1"
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
    @current_person ||= Person.find_by_id(session[:person_id]) if session[:person_id]
    @current_person
  end
  helper_method :current_person

  def get_guid_from_ticket(ticket)
    begin
      ticket.response.to_s.match(/ssoGuid>([A-Z0-9\-]*)/)[1]
    rescue => e
      raise e.message + ' -- ' + ticket.response.inspect
    end
  end

  def available_locales
    %w{en ru es fr}
  end

  def check_valid_subdomain
    return if request.subdomains.first.blank?
    unless (available_locales + %w[www local stage]).include?(request.subdomains.first)
      redirect_to 'http://' + request.host_with_port.sub(request.subdomains.first, 'www') and return false
    end
  end

  def set_locale
    # if the locale is in the subdomain, use that
    if available_locales.include?(request.subdomains.first)
      I18n.locale = request.subdomains.first
    else
      if params[:locale]
        I18n.locale = params[:locale]
      else
        I18n.locale = 'en'
      end
    end
  end

  def export_i18n_messages
     # generates the Javascript translation file
     SimplesIdeias::I18n.export! if Rails.env.development?
  end

  def current_organization(person = nil)
    person ||= current_person if user_signed_in?
    return nil unless person
    @current_organizations ||= {}
    unless @current_organizations[person]
      if session[:current_organization_id]
        org = person.organization_from_id(session[:current_organization_id])
        # org = nil unless org && (person.organizations.include?(org) || person.organizations.include?(org.parent))
      end
      unless org
        if org = person.primary_organization
          # If they're a contact at their primary org (shouldn't happen), look for another org where they have a different role
          if !person.org_ids[org.id] || (person.org_ids[org.id]['roles'] & Role.leader_ids).blank?
            person.primary_organization = person.organizations.first
          end
          session[:current_organization_id] = person.primary_organization.id
        else
          session[:current_organization_id] = nil
        end
      end
      @current_organizations[person] = org
    end
    @current_organizations[person]
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
      render_404
    else
      #if (!current_organization || current_person.organizations.include?(current_organization)) && wizard_path
        #return wizard_path
      #else
        return '/dashboard'
        #return '/contacts/mine'
      #end
    end
  end
  helper_method :user_root_path

  def wizard_path
    step = current_user.next_wizard_step(current_organization)
    if step
      '/wizard?step=' + step
    end
  end
  helper_method :wizard_path

  def create_person(person_params)
    Person.new_from_params(person_params)
  end

  def ensure_current_org
    unless current_organization
      redirect_to '/wizard' and return false
    end
  end

  def access_denied
    render 'application/access_denied'
    return false
  end

  def is_leader?
    current_user.has_role?(Role::LEADER_ID, current_organization) || is_admin?
  end

  def is_admin?
    current_user.has_role?(Role::ADMIN_ID, current_organization)
  end
  helper_method :is_admin?

  def get_survey
    if params[:keyword]
      @keyword ||= SmsKeyword.where(keyword: params[:keyword]).first
      @survey = @keyword ? @keyword.survey : Survey.find(params[:keyword])
    elsif params[:received_sms_id]
      sms_id = Base62.decode(params[:received_sms_id])
      @sms = SmsSession.find_by_id(sms_id)
      if @sms
        @keyword ||= @sms.sms_keyword
        @survey = @keyword.survey if @keyword
      end
    elsif params[:survey_id] || params[:id] || cookies[:survey_id]
      @survey = Survey.find_by_id(params[:survey_id] || params[:id] || cookies[:survey_id])
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
    if @keyword
      cookies[:keyword] = @keyword.keyword
    end
    if @survey
      cookies[:survey_id] = @survey.id
    else
      return false
    end
  end

  def roles_for_assign
    current_user_roles = current_user.person
                                     .organizational_roles
                                     .where(:organization_id => current_organization)
                                     .collect { |r| Role.find_by_id(r.role_id) }.compact

    if current_user_roles.include? Role.find(1)
      @roles_for_assign = current_organization.roles
    else
      @roles_for_assign = current_organization.roles.delete_if { |role| role == Role.find(1) }
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
		if input_date =~ /^([1-9]|0[1-9]|1[012])\/([1-9]|0[1-9]|[12][1-9]|3[01])\/(19|2\d)\d\d$/
			begin
				get_date = input_date.split('/')
				new_date = Date.parse("#{get_date[2]}-#{get_date[0]}-#{get_date[1]}").strftime("%Y-%m-%d")
			rescue
			end
		end     	
		new_date.present? ? new_date : input_date
  end
end
