require 'csv'
class ContactsController < ApplicationController
  before_filter :get_person
  before_filter :ensure_current_org
  before_filter :authorize
  
  def index
    @organization = current_organization # params[:org_id].present? ? Organization.find_by_id(params[:org_id]) : 
    unless @organization
      redirect_to user_root_path, error: t('contacts.index.which_org')
      return false
    end
    @question_sheets = @organization.question_sheets
    @questions = @organization.all_questions.where("#{PageElement.table_name}.hidden" => false).flatten.uniq
    @hidden_questions = @organization.all_questions.where("#{PageElement.table_name}.hidden" => true).flatten.uniq
    # @people = unassigned_people(@organization)
    if params[:dnc] == 'true'
      @people = @organization.dnc_contacts
    elsif params[:completed] == 'true'
      @people = @organization.completed_contacts
    else
      params[:assigned_to] ||= 'all'
      if params[:assigned_to]
        case params[:assigned_to]
        when 'all'
          @people = @organization.contacts
        when 'unassigned'
          @people = unassigned_people(@organization)
        when 'progress'
          @people = @organization.inprogress_contacts
        when 'no_activity'
          @people = @organization.no_activity_contacts
        when 'friends'
          @people = current_person.contact_friends(@organization)
        when *Rejoicable::OPTIONS
          @people = @organization.send(:"#{params[:assigned_to]}_contacts")
        else
          if params[:assigned_to].present? && @assigned_to = Person.find_by_personID(params[:assigned_to])
            @people = Person.includes(:assigned_tos).where('contact_assignments.organization_id' => @organization.id, 'contact_assignments.assigned_to_id' => @assigned_to.id)
          end
        end
      end
      @people ||= Person.where("1=0")
    end
    @people = @people.includes(:organizational_roles).where("organizational_roles.organization_id" => @organization.id)
    if params[:q] && params[:q][:s].include?('mh_answer_sheets')
      @people = @people.joins({:answer_sheets => :question_sheet}).joins("LEFT JOIN sms_keywords on sms_keywords.id = mh_question_sheets.questionnable_id").where("sms_keywords.organization_id" => @organization.id)
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
    if params[:phone_number].present?
      @people = @people.where("phone_numbers.number like ?", '%' + PhoneNumber.strip_us_country_code(params[:phone_number]) + '%')
    end
    if params[:gender].present?
      @people = @people.where("gender = ?", params[:gender].strip)
    end
    if params[:status].present?
      @people = @people.where("organizational_roles.followup_status" => params[:status].strip)
    end
    if params[:answers].present?
      params[:answers].each do |q_id, v|
        question = Element.find(q_id)
        if v.is_a?(String)
          # If this question is assigned to a column, we need to handle that differently
          if question.object_name.present?
            table_name = case question.object_name
                         when 'person'
                           case question.attribute_name
                           when 'email'
                             @people = @people.includes(:email_addresses).where("#{EmailAddress.table_name}.email like ?", '%' + v + '%') unless v.strip.blank?
                           else
                             @people = @people.where("#{Person.table_name}.#{question.attribute_name} like ?", '%' + v + '%') unless v.strip.blank?
                           end
                         end
          else
            @people = @people.joins(:answer_sheets)
            @people = @people.joins("INNER JOIN `mh_answers` as a#{q_id} ON a#{q_id}.`answer_sheet_id` = `mh_answer_sheets`.`id`").where("a#{q_id}.question_id = ? AND a#{q_id}.value like ?", q_id, '%' + v + '%') unless v.strip.blank?
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
            @people = @people.joins(:answer_sheets => :answers).where(conditions) 
          end
        end
      end
    end
    @q = Person.where('1 <> 1').search(params[:q]) # Fake a search object for sorting
    # raise @q.sorts.inspect
    @people = @people.includes(:primary_phone_number, :primary_email_address).order(params[:q] && params[:q][:s] ? params[:q][:s] : ['lastName, firstName']).group('ministry_person.personID')
    @all_people = @people
    @people = @people.page(params[:page])
    
    respond_to do |wants|
      wants.html do
        @roles = Hash[OrganizationalRole.active.where(organization_id: @organization.id, role_id: Role::CONTACT_ID, person_id: @people.collect(&:id)).map {|r| [r.person_id, r]}]
        @assignments = ContactAssignment.includes(:assigned_to).where(person_id: @people.collect(&:id), organization_id: @organization.id).group_by(&:person_id)
        @answers = generate_answers(@people, @organization, @questions)
      end
      wants.csv do
        @roles = Hash[OrganizationalRole.active.where(organization_id: @organization.id, role_id: Role::CONTACT_ID, person_id: @all_people.collect(&:id)).map {|r| [r.person_id, r]}]
        @all_answers = generate_answers(@all_people, @organization, @questions)
        out = ""
        CSV.generate(out) do |rows|
          rows << [t('contacts.index.first_name'), t('contacts.index.last_name'), t('general.status'), t('general.gender'), t('contacts.index.phone_number')] + @questions.collect {|q| q.label} + [t('contacts.index.last_survey')]
          @all_people.each do |person|
            if @roles[person.id]
              answers = [person.firstName, person.lastName, @roles[person.id].followup_status.to_s.titleize, person.gender.to_s.titleize, person.pretty_phone_number]
              dates = []
              @questions.each do |q|
                answer = @all_answers[person.id][q.id]
                if answer
                  answers << answer.first
                  dates << answer.last
                else
                  answers << ''
                end
                # answer_sheet = person.answer_sheets.detect {|as| q.question_sheets.collect(&:id).include?(as.question_sheet_id)}
                # answers << q.display_response(answer_sheet)
              end
              answers << I18n.l(dates.sort.last, format: :date) if dates.present?
              rows << answers
            end
          end
        end
        filename = @organization.to_s
        send_data(out, :filename => "#{filename} - Contacts.csv", :type => 'application/csv' )
      end
    end
  end
  
  def mine
    @people = Person.order('lastName, firstName').includes(:assigned_tos, :organizational_roles).where('contact_assignments.organization_id' => current_organization.id, 'contact_assignments.assigned_to_id' => current_person.id, 'organizational_roles.role_id' => Role::CONTACT_ID)
    if params[:status] == 'completed'
      @people = @people.where("organizational_roles.followup_status = 'completed'")
    else
      @people = @people.where("organizational_roles.followup_status <> 'completed'")
    end
  end
  
  def update
    @person = Person.find(params[:id])
    authorize!(:update, @person)
    
    @person.update_attributes(params[:person]) if params[:person]
    
    save_survey_answers

    if @person.valid? && (!@answer_sheet || (@answer_sheet.person.valid? &&
       (!@answer_sheet.person.primary_phone_number || @answer_sheet.person.primary_phone_number.valid?)))
      redirect_to contact_path(@person)
    else
      render :edit
    end
  end
  
  def show
    @person = Person.find(params[:id])
    @organization = current_organization
    @organizational_role = OrganizationalRole.where(organization_id: @organization, person_id: @person, role_id: Role::CONTACT_ID).first
    authorize!(:read, @person)
    @followup_comment = FollowupComment.new(organization: @organization, commenter: current_person, contact: @person, status: @organizational_role.followup_status) if @organizational_role
    @followup_comments = FollowupComment.where(organization_id: @organization, contact_id: @person).order('created_at desc')
  end
  
  def edit
    @person = Person.find(params[:id])
    authorize!(:update, @person)
  end
  
  def create
    Person.transaction do
      params[:person] ||= {}
      params[:person][:email_address] ||= {}
      params[:person][:phone_number] ||= {}
      unless params[:person][:firstName].present?# && (params[:person][:email_address][:email].present? || params[:person][:phone_number][:number].present?)
        render :nothing => true and return
      end
      @person, @email, @phone = create_person(params[:person])
      if @person.save

        @questions = current_organization.all_questions.where("#{PageElement.table_name}.hidden" => false)

        save_survey_answers
      
        FollowupComment.create_from_survey(current_organization, @person, current_organization.all_questions, @answer_sheets)

        create_contact_at_org(@person, current_organization)
        if params[:assign_to_me] == 'true'
          ContactAssignment.where(person_id: @person.id, organization_id: current_organization.id).destroy_all
          ContactAssignment.create!(person_id: @person.id, organization_id: current_organization.id, assigned_to_id: current_person.id)
        end
        respond_to do |wants|
          wants.html { redirect_to :back }
          wants.mobile { redirect_to :back }
          wants.js do
            @assignments = ContactAssignment.where(person_id: @person.id, organization_id: current_organization.id).group_by(&:person_id)
            @roles = Hash[OrganizationalRole.active.where(organization_id: current_organization.id, role_id: Role::CONTACT_ID, person_id: @person).map {|r| [r.person_id, r]}]
            @answers = generate_answers([@person], current_organization, @questions)
          end
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
  end
  
  def destroy
    contact = Person.find(params[:id])
    current_organization.remove_contact(contact)

    render :nothing => true      
  end
  
  def bulk_destroy
    params[:ids].each do |id|
      contact = Person.find(id)
      current_organization.remove_contact(contact)
    end

    render :nothing => true    
  end
  
  def send_reminder
    to_ids = params[:to].split(',')
    leaders = current_organization.leaders.where(personID: to_ids)
    if leaders.present?
      ContactsMailer.reminder(leaders.collect(&:email).compact, current_person.email, params[:subject], params[:body]).deliver
    end
    render nothing: true
  end
  
  def send_vcard
    require 'vpim/vcard'
    
    @person = Person.find(params[:id])
    card = Vpim::Vcard::Maker.make2 do |maker|
      maker.add_name do |name|
        name.prefix = ''
        name.given = @person.firstName
        name.family = @person.lastName
      end
      maker.add_addr do |addr|
        addr.preferred = true
        addr.location = 'home'
        addr.street =  @person.current_address.address1 + ' ' + @person.current_address.address2
        addr.locality = @person.current_address.city
        addr.postalcode = @person.current_address.zip
        addr.region = @person.current_address.state
        addr.country = @person.current_address.country
      end
      
      maker.birthday = @person.birth_date
      maker.add_tel(@person.phone_number)
      maker.add_email(@person.email) do |email|
        email.preferred = true
        email.location = 'home'
      end  

    end

    send_data card.to_s, :filename => "contact.vcf"    
  end
  
  protected
  
    def save_survey_answers
      @answer_sheets = []
      current_organization.keywords.each do |keyword|
        @answer_sheet = get_answer_sheet(keyword, @person)
        question_set = QuestionSet.new(keyword.questions, @answer_sheet)
        question_set.post(params[:answers], @answer_sheet)
        question_set.save
        @answer_sheets << @answer_sheet
      end
    end
    
    def get_person
      @person = user_signed_in? ? current_user.person : Person.new
    end
    
    def authorize
      authorize! :manage_contacts, current_organization
    end
    
    def generate_answers(people, organization, questions)
      answers = {}
      people.each do |person|
        answers[person.id] = {}
      end
      @surveys = {}
      AnswerSheet.where(question_sheet_id: organization.question_sheet_ids, person_id: people.collect(&:id)).includes(:answers, {:person => :primary_email_address}).each do |answer_sheet|
        @surveys[answer_sheet.person_id] ||= {}
        @surveys[answer_sheet.person_id][answer_sheet.question_sheet.questionnable.to_s] = answer_sheet.updated_at
        
        answers[answer_sheet.person_id] ||= {}
        questions.each do |q|
          answers[answer_sheet.person_id][q.id] = [q.display_response(answer_sheet), answer_sheet.created_at] if q.display_response(answer_sheet).present?
        end
      end
      answers
    end
end
