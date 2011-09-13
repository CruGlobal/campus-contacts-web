class ContactsController < ApplicationController
  prepend_before_filter :set_keyword_cookie, only: :new
  before_filter :get_person
  before_filter :prepare_for_mobile, only: [:new, :update, :thanks]
  before_filter :get_keyword, only: [:new, :update, :thanks]
  before_filter :ensure_current_org, except: [:new, :update, :thanks]
  before_filter :authorize, except: [:new, :update, :thanks]
  skip_before_filter :check_url, only: [:new, :update]
  
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
          @people = unassigned_people(@organization).order('lastName, firstName')
        when 'progress'
          @people = @organization.inprogress_contacts.order('lastName, firstName')
        when 'no_activity'
          @people = @organization.no_activity_contacts.order('lastName, firstName')
        when 'friends'
          @people = current_person.contact_friends(current_organization)
        when *Rejoicable::OPTIONS
          @people = @organization.send(:"#{params[:assigned_to]}_contacts").order('lastName, firstName')
        else
          if params[:assigned_to].present? && @assigned_to = Person.find_by_personID(params[:assigned_to])
            @people = Person.order('lastName, firstName').includes(:assigned_tos).where('contact_assignments.organization_id' => @organization.id, 'contact_assignments.assigned_to_id' => @assigned_to.id)
          end
        end
      end
      @people ||= Person.where("1=0")
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
      @people = @people.includes(:primary_phone_number).where("phone_numbers.number like ?", '%' + PhoneNumber.strip_us_country_code(params[:phone_number]) + '%')
    end
    if params[:gender].present?
      @people = @people.where("gender = ?", params[:gender].strip)
    end
    if params[:status].present?
      @people = @people.includes(:organizational_roles).where("organizational_roles.followup_status = ?", params[:status].strip)
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
    @all_people = @people
    @people = @people.page(params[:page])
    respond_to do |wants|
      wants.html do
        @roles = Hash[OrganizationalRole.active.where(role_id: Role::CONTACT_ID, person_id: @people.collect(&:id)).map {|r| [r.person_id, r]}]
      end
      wants.csv do
        @roles = Hash[OrganizationalRole.active.where(role_id: Role::CONTACT_ID, person_id: @all_people.collect(&:id)).map {|r| [r.person_id, r]}]
        out = ""
        CSV.generate(out) do |rows|
          rows << [t('contacts.index.first_name'), t('contacts.index.last_name'), t('general.status'), t('general.gender'), t('contacts.index.phone_number')] + @questions.collect {|q| q.label}
          @all_people.each do |person|
            answers = [person.firstName, person.lastName, @roles[person.id].followup_status.to_s.titleize, person.gender.to_s.titleize, person.pretty_phone_number]
            @questions.each do |q|
              answer_sheet = person.answer_sheets.detect {|as| q.question_sheets.collect(&:id).include?(as.question_sheet_id)}
              answers << q.display_response(answer_sheet)
            end
            rows << answers
          end
        end
        filename = current_organization.to_s
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
  
  def new
    unless mhub? || Rails.env.test?
      redirect_to new_contact_url(params.merge(host: APP_CONFIG['public_host'], port: APP_CONFIG['public_port']))
      return false
    end
    
    if @sms
      @person.phone_numbers.create!(number: @sms.phone_number, location: 'mobile') unless @person.phone_numbers.detect {|p| p.number_with_country_code == @sms.phone_number}
      @sms.update_attribute(:person_id, @person.id) unless @sms.person_id
    end
    if @keyword
      @answer_sheet = get_answer_sheet(@keyword, @person)
      respond_to do |wants|
        wants.html { render :layout => 'plain'}
        wants.mobile
      end
    else
      render_404 and return
    end
  end
    
  def update
    person_to_update = Person.find(params[:id])
    @person = person_to_update if can?(:update, person_to_update)
    @person.update_attributes(params[:person]) if params[:person]
    keywords = @keyword ? [@keyword] : current_organization.keywords
    keywords.each do |keyword|
      @answer_sheet = get_answer_sheet(keyword, @person)
      question_set = QuestionSet.new(keyword.questions, @answer_sheet)
      question_set.post(params[:answers], @answer_sheet)
      question_set.save
    end
    if @person.valid? && (!@answer_sheet || (@answer_sheet.person.valid? &&
       (!@answer_sheet.person.primary_phone_number || @answer_sheet.person.primary_phone_number.valid?)))
      create_contact_at_org(@person, @keyword.organization) if @keyword
      respond_to do |wants|
        wants.html do
          if mhub?
            render :thanks, layout: 'plain'
          else
            redirect_to contact_path(@person)
          end
        end
        wants.mobile { render :thanks }
      end
    else
      if mhub?
        render :new, layout: 'plain'
      else
        render :edit
      end
    end
  end
  
  def show
    @person = Person.find(params[:id])
    @organization = current_organization
    @organizational_role = OrganizationalRole.where(organization_id: @organization, person_id: @person, role_id: Role::CONTACT_ID).first
    unless @organizational_role
      redirect_to '/404.html' and return
    end
    @followup_comment = FollowupComment.new(organization: @organization, commenter: current_person, contact: @person, status: @organizational_role.followup_status)
    @followup_comments = FollowupComment.where(organization_id: @organization, contact_id: @person).order('created_at desc')
  end
  
  def edit
    @person = Person.find(params[:id])
    authorize!(:update, @person)
  end
  
  def create
    params[:person] ||= {}
    params[:person][:email_address] ||= {}
    params[:person][:phone_number] ||= {}
    unless params[:person][:firstName].present? && (params[:person][:email_address][:email].present? || params[:person][:phone_number][:number].present?)
      render :nothing => true and return
    end
    @person, @email, @phone = create_person(params[:person])
    if @person.save
      # @email.save
      # @phone.save
      # save survey answers
      current_organization.keywords.each do |keyword|
        @answer_sheet = get_answer_sheet(keyword, @person)
        question_set = QuestionSet.new(keyword.questions, @answer_sheet)
        question_set.post(params[:answers], @answer_sheet)
        question_set.save
      end
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
    respond_to do |wants|
      wants.html { redirect_to :back }
      wants.mobile { redirect_to :back }
      wants.js
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
      if params[:keyword]
        @keyword ||= SmsKeyword.where(keyword: params[:keyword]).first 
      elsif params[:received_sms_id]
        sms_id = Base62.decode(params[:received_sms_id])
        @sms = SmsSession.find_by_id(sms_id) || ReceivedSms.find_by_id(sms_id)
        if @sms
          @keyword ||= @sms.sms_keyword || SmsKeyword.where(keyword: @sms.message.strip).first
        end
      end
      if params[:keyword] || params[:received_sms_id]
        unless @keyword
          render_404 
          return false
        end
        @questions = @keyword.questions
      end
    end
    
    def set_keyword_cookie
      get_keyword
      if @keyword
        cookies[:keyword] = @keyword.keyword 
      else
        return false
      end
    end
    
    def get_person
      @person = current_user.person
    end
    
    def authorize
      authorize! :manage_contacts, current_organization
    end
end
