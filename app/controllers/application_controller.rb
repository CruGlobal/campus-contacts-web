class ApplicationController < ActionController::Base
  before_filter :authenticate_user!, :prepare_for_mobile, :set_locale
  protect_from_forgery  

  def facebook_logout
    split_token = session[:fb_token].split("|")
    fb_api_key = split_token[0]
    fb_session_key = split_token[1]
    redirect_to "http://www.facebook.com/logout.php?api_key=#{fb_api_key}&session_key=#{fb_session_key}&confirm=1&next=#{destroy_user_session_url}";
  end

  protected
  
  def self.application_name
    'MH'
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
    I18n.locale = params[:locale] if params[:locale]
  end
  
  def current_organization
    return nil unless user_signed_in?
    return nil if current_person.organizations.empty?
    org = current_person.organizations.find_by_id(session[:current_organization_id]) 
    unless org
      org = current_person.primary_organization || current_person.organizations.first
      session[:current_organization_id] = org.id
    end
    org
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
    @unassigned_people ||= Person.joins("INNER JOIN organizational_roles ON organizational_roles.person_id = #{Person.table_name}.#{Person.primary_key} AND organizational_roles.organization_id = #{organization.id} AND organizational_roles.role_id = '#{Role.contact.id}' AND followup_status <> 'do_not_contact' LEFT JOIN contact_assignments ON contact_assignments.person_id = #{Person.table_name}.#{Person.primary_key}  AND contact_assignments.organization_id = #{@organization.id}").where('contact_assignments.id' => nil)
  end
  helper_method :unassigned_people
  
  def unassigned_people_api(people,organization)
    @unassigned_people ||= people.joins("INNER JOIN organizational_roles ON organizational_roles.person_id = #{Person.table_name}.#{Person.primary_key} AND organizational_roles.organization_id = #{organization.id} AND organizational_roles.role_id = '#{Role.contact.id}' AND followup_status <> 'do_not_contact' LEFT OUTER JOIN contact_assignments ON contact_assignments.person_id = #{Person.table_name}.#{Person.primary_key} AND contact_assignments.organization_id = #{@organization.id}").where('contact_assignments.id' => nil)
  end
  helper_method :unassigned_people_api
  
  def get_answer_sheet(keyword, person)
    @answer_sheet = AnswerSheet.where(person_id: person.id, question_sheet_id: keyword.question_sheet.id).first || 
                    AnswerSheet.create!(person_id: person.id, question_sheet_id: keyword.question_sheet.id)
    @answer_sheet.reload
    @answer_sheet
  end
  
  def create_contact_at_org(person, organization)
    unless OrganizationMembership.find_by_person_id_and_organization_id(person.id, organization.id)
      OrganizationMembership.create!(person_id: person.id, organization_id: organization.id) 
      OrganizationalRole.create!(person_id: person.id, organization_id: organization.id, role_id: Role.contact.id, followup_status: OrganizationMembership::FOLLOWUP_STATUSES.first)
    end
  end
  
  def user_root_path
    return '/wizard' unless current_organization
    # if current_person.leader_in?(current_organization)
      '/contacts/mine'
    # else
      # '/people'
    # end
  end
  helper_method :user_root_path
  
  def wizard_path
    '/wizard?step=' + current_user.next_wizard_step(current_organization)
  end
  helper_method :wizard_path
  
  def create_person(person_params)
    person_params ||= {}
    person_params[:email_address] ||= {}
    person_params[:phone_number] ||= {}
    # try to find this person based on their email address
    if (email = person_params[:email_address][:email]).present?
      @person = EmailAddress.find_by_email(email).try(:person) ||
                Address.find_by_email(email).try(:person) ||
                User.find_by_username(email).try(:person) 
    end
    @person ||= Person.new(person_params.except(:email_address, :phone_number))
    @email = @person.email_addresses.find_by_email(person_params[:email_address][:email]) || @person.email_addresses.new(person_params.delete(:email_address)) if person_params[:email_address][:email].present? 
    @phone = @person.phone_numbers.find_by_number(person_params[:phone_number][:number]) || @person.phone_numbers.new(person_params.delete(:phone_number).merge(location: 'mobile')) if person_params[:phone_number][:number].present?
    @person
  end
  
  def ensure_current_org
    unless current_organization
      redirect_to '/wizard' and return false
    end
  end
  
end
