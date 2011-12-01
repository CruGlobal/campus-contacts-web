class ApplicationController < ActionController::Base
  extend DelegatePresenter::ApplicationController
  before_filter :authenticate_user!, :except => [:facebook_logout]
  before_filter :set_login_cookie
  before_filter :check_su
  before_filter :set_locale
  before_filter :check_url, except: :facebook_logout
  before_filter :export_i18n_messages
  before_filter :set_newrelic_params
  
  rescue_from CanCan::AccessDenied, with: :access_denied
  protect_from_forgery  

  
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
  
  def raise_or_hoptoad(e)
    if Rails.env.production? 
      Airbrake.notify(e)
    else
      raise e
    end
  end
  helper_method :raise_or_hoptoad
  
  def check_url
    render_404 if mhub?
  end
  
  def render_404
    if cookies[:keyword] && SmsKeyword.find_by_keyword(cookies[:keyword])
      redirect_to "/c/#{cookies[:keyword]}"
    else
      render :file => Rails.root.join(mhub? ? 'public/404_mhub.html' : 'public/404.html'), :layout => false, :status => 404
    end
    return false
  end
  
  def mhub?
    @mhub = request.host.include?('mhub.cc') if @mhub.nil?
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
    session['fb_token'] = nil
    session['current_organization_id'] = nil
    session['warden.user.user.key'] = ["User", [user_id.to_i], nil]
    session['wizard'] = nil
  end
  
  def current_user
    # check for access token, then do it the devise way
    if params['access_token']
      @current_user ||= User.find(Rack::OAuth2::Server.get_access_token(params['access_token']).identity)
    else
      super # devise user
    end
  end
  
  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end
  helper_method :mobile_device?

  def prepare_for_mobile
    session[:mobile_param] = params[:mobile] if params[:mobile]
    request.format = :mobile if mobile_device?
  end
  
  def current_person
    current_user.person
  end
  helper_method :current_person
  
  def get_guid_from_ticket(ticket)
    begin
      ticket.response.to_s.match(/ssoGuid>([A-Z0-9\-]*)/)[1]
    rescue => e
      raise e.message + ' -- ' + ticket.response.inspect
    end
  end
  
  def set_locale
    if params[:locale]
      I18n.locale = params[:locale] 
    else
      available = %w{en ru}
      I18n.locale = request.preferred_language_from(available)
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
        org = Organization.find_by_id(session[:current_organization_id]) 
        # org = nil unless org && (person.organizations.include?(org) || person.organizations.include?(org.parent))
      end
      unless org
        org = person.primary_organization
        # If they're a contact at their primary org (shouldn't happen), look for another org where they have a different role
        unless person.organizations.include?(org)
          org = person.organizations.first
        end
        session[:current_organization_id] = org.try(:id)
      end
      @current_organizations[person] = org
    end
    @current_organizations[person]
  end
  helper_method :current_organization
  
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
  # end
  
  def unassigned_people(organization)
    @unassigned_people ||= organization.unassigned_people
  end
  helper_method :unassigned_people
  
  def get_answer_sheet(keyword, person)
    answer_sheet = AnswerSheet.where(person_id: person.id, question_sheet_id: keyword.question_sheet.id).first || 
                   AnswerSheet.create!(person_id: person.id, question_sheet_id: keyword.question_sheet.id)
    answer_sheet.reload
    answer_sheet
  end
  
  def create_contact_at_org(person, organization)
    # if someone already has a status in an org, we shouldn't add them as a contact
    raise 'no person' unless person
    raise 'no org' unless organization
    organization.add_contact(person)
  end
  
  def user_root_path
    if mhub?
      render_404
    else
      return wizard_path if !current_organization || (current_person.organizations.include?(current_organization) && wizard_path)
      # if current_person.leader_in?(current_organization)
        '/contacts/mine'
      # else
        # '/people'
      # end
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
    Person.create_from_params(person_params)
  end
  
  def ensure_current_org
    unless current_organization
      redirect_to '/wizard' and return false
    end
  end
  
  def access_denied
    flash[:alert] =  "You don't have permission to access that area of MissionHub"
    render 'application/access_denied'
    return false
  end
  
  def is_leader?
    current_user.has_role?(Role::LEADER_ID, current_organization) || is_admin?
  end
  
  def is_admin?
    current_user.has_role?(Role::ADMIN_ID, current_organization)
  end
  
end
