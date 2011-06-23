class ApplicationController < ActionController::Base
  before_filter :authenticate_user!, :prepare_for_mobile, :set_locale
  protect_from_forgery  

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
    org = current_person.organizations.find_by_id(session[:current_organization_id]) if session[:current_organization_id] 
    org ||= current_person.primary_organization
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
    @unassigned_people ||= Person.joins("INNER JOIN organization_memberships ON organization_memberships.person_id = #{Person.table_name}.#{Person.primary_key} AND organization_memberships.organization_id = #{organization.id} AND organization_memberships.role = 'contact' LEFT JOIN contact_assignments ON contact_assignments.person_id = #{Person.table_name}.#{Person.primary_key}").where('contact_assignments.id' => nil)
  end
  helper_method :unassigned_people
  
  def get_answer_sheet(keyword, person)
    @answer_sheet = AnswerSheet.where(:person_id => person.id, :question_sheet_id => keyword.question_sheet.id).first || 
                    AnswerSheet.create!(:person_id => person.id, :question_sheet_id => keyword.question_sheet.id)
    @answer_sheet.reload
    @answer_sheet
  end
  
  def create_contact_at_org(person, organization)
    # Make them a contact of the org associated with this keyword
    unless OrganizationMembership.find_by_person_id_and_organization_id(person.id, organization.id)
      OrganizationMembership.create!(:person_id => person.id, :organization_id => organization.id, :role => 'contact', :followup_status => OrganizationMembership::FOLLOWUP_STATUSES.first) 
    end
  end
  
  def user_root_path
    return '/wizard' unless current_organization
    if current_person.leader_in?(current_organization)
      '/contacts/mine'
    else
      '/people'
    end
  end
  helper_method :user_root_path
  
  def wizard_path
    '/wizard?step=' + current_user.next_wizard_step(current_organization)
  end
  helper_method :wizard_path
  
end
