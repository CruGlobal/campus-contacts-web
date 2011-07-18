class ContactsController < ApplicationController
  before_filter :get_person
  before_filter :prepare_for_mobile, only: [:new, :update, :thanks]
  before_filter :get_keyword, only: [:new, :update, :thanks]
  before_filter :ensure_current_org, except: [:new, :update, :thanks]
  before_filter :authorize, except: [:new, :update, :thanks]
  
  def index
    @organization = params[:org_id].present? ? Organization.find_by_id(params[:org_id]) : current_organization
    unless @organization
      redirect_to user_root_path, error: t('contacts.index.which_org')
      return false
    end
    @question_sheets = @organization.question_sheets
    @questions = @organization.questions.where("#{PageElement.table_name}.hidden" => false).flatten.uniq
    @hidden_questions = @organization.questions.where("#{PageElement.table_name}.hidden" => true).flatten.uniq
    # @people = unassigned_people(@organization)
    if params[:dnc] == 'true'
      @people = @organization.dnc_contacts.order('lastName, firstName')
    elsif params[:completed] == 'true'
      @people = @organization.completed_contacts.order('lastName, firstName')
    else
      params[:assigned_to] ||= 'all'
      if params[:assigned_to]
        case params[:assigned_to]
        when 'all'
          @people = @organization.contacts.order('lastName, firstName')
        when 'unassigned'
          @people = unassigned_people(@organization)
        when 'progress'
          @people = @organization.inprogress_contacts.order('lastName, firstName')
        when 'friends'
          @people = current_person.contact_friends(current_organization)
        else
          if params[:assigned_to].present? && @assigned_to = Person.find_by_personID(params[:assigned_to])
            @people = Person.order('lastName, firstName').includes(:assigned_tos).where('contact_assignments.organization_id' => @organization.id, 'contact_assignments.assigned_to_id' => @assigned_to.id)
          end
        end
      end
    end
    if params[:first_name].present?
      @people = @people.where("firstName like ? OR preferredName like ?", '%' + params[:first_name].strip + '%', '%' + params[:first_name].strip + '%')
    end
    if params[:last_name].present?
      @people = @people.where("lastName like ?", '%' + params[:last_name].strip + '%')
    end
    if params[:email].present?
      @people = @people.includes(:primary_email_address).where("email_addresses.email like ?", '%' + params[:email].strip + '%')
    end
    
    if params[:answers].present?
      params[:answers].each do |q_id, v|
        question = Element.find(q_id)
        if v.is_a?(String)
          # If this question is assigned to a column, we need to handle that differently
          if question.object_name.present?
            table_name = case question.object_name
                         when 'person'
                           @people = @people.where("#{Person.table_name}.#{question.attribute_name} like ?", '%' + v + '%') unless v.strip.blank?
                         end
          else
            @people = @people.includes(:answer_sheets => :answers).where("#{Answer.table_name}.question_id = ? AND #{Answer.table_name}.value like ?", q_id, '%' + v + '%') unless v.strip.blank?
          end
        else
          conditions = ["#{Answer.table_name}.question_id = ?", q_id]
          answers_conditions = []
          v.each do |k1, v1| 
            unless v1.strip.blank?
              answers_conditions << "#{Answer.table_name}.value like ?"
              conditions << v1
            end
          end
          if answers_conditions.present?
            conditions[0] = conditions[0] + ' AND (' + answers_conditions.join(' OR ') + ')'
            @people = @people.includes(:answer_sheets => :answers).where(conditions) 
          end
        end
      end
    end
  end
  
  def mine
    @people = Person.order('lastName, firstName').includes(:assigned_tos, :organizational_roles).where('contact_assignments.organization_id' => current_organization.id, 'contact_assignments.assigned_to_id' => current_person.id, 'organizational_roles.role_id' => Role.contact.id)
    if params[:status] == 'completed'
      @people = @people.where("organizational_roles.followup_status = 'completed'")
    else
      @people = @people.where("organizational_roles.followup_status <> 'completed'")
    end
  end
  
  def new
    if params[:received_sms_id]
      sms = ReceivedSms.find_by_id(Base62.decode(params[:received_sms_id])) 
      if sms
        @keyword ||= SmsKeyword.where(keyword: sms.message).first
        @person.phone_numbers.create!(number: sms.phone_number, location: 'mobile') unless @person.phone_numbers.detect {|p| p.number_with_country_code == sms.phone_number}
        sms.update_attribute(:person_id, @person.id) unless sms.person_id
      end
    end
    get_answer_sheet(@keyword, @person)
    respond_to do |wants|
      wants.html { render :layout => 'plain'}
      wants.mobile
    end
  end
    
  def update
    get_answer_sheet(@keyword, @person)
    @person.update_attributes(params[:person]) if params[:person]
    question_set = QuestionSet.new(@keyword.questions, @answer_sheet)
    question_set.post(params[:answers], @answer_sheet)
    question_set.save
    if @person.valid? && @answer_sheet.person.valid? &&
       (!@answer_sheet.person.primary_phone_number || @answer_sheet.person.primary_phone_number.valid?)
      create_contact_at_org(@person, @keyword.organization)
      respond_to do |wants|
        wants.html { render :thanks, layout: 'plain'}
        wants.mobile { render :thanks }
      end
    else
      render :new, layout: 'plain'
    end
  end
  
  def show
    @person = Person.find(params[:id])
    @organization = current_organization
    @organizational_role = OrganizationalRole.where(organization_id: @organization, person_id: @person, role_id: Role.contact.id).first
    unless @organizational_role
      redirect_to '/404.html' and return
    end
    @followup_comment = FollowupComment.new(organization: @organization, commenter: current_person, contact: @person, status: @organizational_role.followup_status)
    @followup_comments = FollowupComment.where(organization_id: @organization, contact_id: @person).order('created_at desc')
  end
  
  
  def create
    params[:person] ||= {}
    params[:person][:email_address] ||= {}
    params[:person][:phone_number] ||= {}
    unless params[:person][:firstName].present? && (params[:person][:email_address][:email].present? || params[:person][:phone_number][:number].present?)
      render :nothing => true and return
    end
    @person = create_person(params[:person])
    if @person.save
      create_contact_at_org(@person, current_organization)
      if params[:assign_to_me] == 'true'
        ContactAssignment.where(person_id: @person.id, organization_id: current_organization.id).destroy_all
        ContactAssignment.create!(person_id: @person.id, organization_id: current_organization.id, assigned_to_id: current_person.id)
      end
    else
      flash.now[:error] = ''
      flash.now[:error] += 'First name is required.<br />' unless @person.firstName.present?
      flash.now[:error] += 'Phone number is not valid.<br />' if @phone && !@phone.valid?
      flash.now[:error] += 'Email address is not valid.<br />' if @email && !@email.valid?
      render 'add_contact'
      return
    end
  end
  
  def send_reminder
    to_ids = params[:to].split(',')
    leaders = current_organization.leaders.where(personID: to_ids)
    if leaders.present?
      ContactsMailer.reminder(leaders.collect(&:email).compact, current_person.email, params[:subject], params[:body]).deliver
    end
    render nothing: true
  end
  
  protected
    
    def get_keyword
      @keyword = SmsKeyword.where(keyword: params[:keyword]).first if params[:keyword]
    end
    
    def get_person
      @person = current_user.person
    end
    
    def authorize
      authorize! :manage_contacts, current_organization
    end
end
