require 'csv'
require 'contact_actions'

class ContactsController < ApplicationController
  include ContactActions
  include ActionView::Helpers::DateHelper
  
  before_filter :get_person
  before_filter :ensure_current_org
  before_filter :authorize
  before_filter :roles_for_assign

  rescue_from OrganizationalRole::InvalidPersonAttributesError do |exception|
    #render 'update_leader_error'
  end
  
  def index
    @saved_contact_search = @person.user.saved_contact_searches.find(:first, :conditions => "full_path = '#{request.fullpath}'") || SavedContactSearch.new
    @organization = current_organization # params[:org_id].present? ? Organization.find_by_id(params[:org_id]) : 
    unless @organization
      redirect_to user_root_path, error: t('contacts.index.which_org')
      return false
    end
    @surveys = @organization.surveys
    @questions = @organization.all_questions.where("#{SurveyElement.table_name}.hidden" => false).flatten.uniq
    @hidden_questions = @organization.all_questions.where("#{SurveyElement.table_name}.hidden" => true).flatten.uniq
    @people = unassigned_people(@organization)
    if params[:dnc] == 'true'
      @people = @organization.dnc_contacts
    elsif params[:completed] == 'true'
      @people = @organization.completed_contacts
    else
      params[:assigned_to] = nil if params[:assigned_to].blank?
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
    unless @people.arel.to_sql.include?('JOIN organizational_roles')
      @people = @people.includes(:organizational_roles).where("organizational_roles.organization_id" => @organization.id)
    end
    if params[:q] && params[:q][:s].include?('mh_answer_sheets')
      @people = @people.joins({:answer_sheets => :survey}).where("mh_surveys.organization_id" => @organization.id)
    end
    if params[:survey].present?
      @people = @people.joins(:answer_sheets).where("mh_answer_sheets.survey_id" => params[:survey])
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
            unless v.strip.blank?
              @people = @people.joins(:answer_sheets)
              @people = @people.joins("INNER JOIN `mh_answers` as a#{q_id} ON a#{q_id}.`answer_sheet_id` = `mh_answer_sheets`.`id`").where("a#{q_id}.question_id = ? AND a#{q_id}.value like ?", q_id, '%' + v + '%')
            end
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
    if params[:person_updated_from].present? && params[:person_updated_to].present?
      @people = @people.find_by_person_updated_by_daterange(params[:person_updated_from], params[:person_updated_to])
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
    @people = Person.order('lastName, firstName').includes(:assigned_tos, :organizational_roles).where('contact_assignments.organization_id' => current_organization.id, 'contact_assignments.assigned_to_id' => current_person.id, 'organizational_roles.organization_id' => current_organization.id, 'organizational_roles.role_id' => Role::CONTACT_ID)
    if params[:status] == 'completed'
      @people = @people.where("organizational_roles.followup_status = 'completed'")
    elsif params[:status] == 'all'
      
    else
      @people = @people.where("organizational_roles.followup_status <> 'completed'")
    end
  end
  
  def update
    @person = Person.find(params[:id])
    authorize!(:update, @person)
    
    @person.update_attributes(params[:person]) if params[:person]
    
    save_survey_answers
    @person.update_date_attributes_updated
    if @person.valid? && (!@answer_sheet || (@answer_sheet.person.valid? &&
       (!@answer_sheet.person.primary_phone_number || @answer_sheet.person.primary_phone_number.valid?)))
      redirect_to survey_response_path(@person)
    else
      render :edit
    end
  end
  
  def show
    redirect_to person_path(params[:id])
  end
  
  def edit
    redirect_to survey_response_path(params[:id])
  end
  
  def create
    @organization = current_organization
    create_contact
  end
  
  def destroy
    contact = Person.find(params[:id])
    authorize! :manage, contact
    current_organization.remove_contact(contact)

    render :nothing => true      
  end
  
  def bulk_destroy
    authorize! :manage, current_organization
    Person.find(params[:ids]).each do |contact|
      current_organization.remove_contact(contact)
    end

    render :nothing => true    
  end
  
  def send_reminder
    to_ids = params[:to].split(',')
    leaders = current_organization.leaders.where(personID: to_ids)
    if leaders.present?
      ContactsMailer.enqueue.reminder(leaders.collect(&:email).compact, current_person.email, params[:subject], params[:body])
    end
    render nothing: true
  end

  def import_contacts
    @organization = current_organization
  end

  def csv_import
    @organization = current_organization

    n = 0
    error = false
    success = false
    flash_error = ""
    a = Array.new
    puts "=========> #{params[:dump][:file].path.to_s}"
    CSV.foreach(params[:dump][:file].path.to_s) do |row|
      if n == 0
        n = n + 1
        next
      end
      
      n += 1

      if !row[0].to_s.match /[a-z]/ # if firstName is blank
        flash_error = flash_error + "#{t('contacts.import_contacts.cause_1')} #{n},"
        error = true
        next
      end

      if row[5].to_s.gsub(/[^\d]/,'').length < 7 && !row[5].nil? # if phone_number length < 7
        flash_error = flash_error + "#{t('contacts.import_contacts.cause_2')} #{n},"
        error = true
        next
      end

      if !row[4].to_s.match(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i) # if email has wrong formatting
        flash_error = flash_error + "#{t('contacts.import_contacts.cause_3')} #{n},"
        error = true
        next
      end
      a << {:person => {:firstName => row[0], :lastName => row[1], :gender => row[3], :email_address => {:email => row[4], :primary => "1", :_destroy => "false"}, :phone_number => {:number => row[5], :location => "mobile", :primary => "1", :_destroy => "false"}, :current_address_attributes => { :address1 => row[6], :address2 => row[7], :city => row[8], :state => row[9], :country => row[10], :zip => row[11]} }}
      success = true
    end

    if success
      a.each do |p|
        create_contact_from_row(p)
      end

      flash.now[:notice] = t('contacts.import_contacts.success')
    end
    flash.now[:error] = t('contacts.import_contacts.error') + flash_error if error
    render :import_contacts
  end

  def download_sample_contacts_csv

    csv_string = CSV.generate do |csv|
      c = 0
      CSV.foreach(Rails.root.to_s + "/public/files/sample_contacts.csv") do |row|
        if c == 0
          current_organization.surveys.flatten.uniq.each do |survey|
            survey.all_questions.each do |q|
              row << q.label
            end
          end
        end
        c = c + 1
        csv << row
      end
    end



    #send_file Rails.root.to_s + '/public' + '/files/sample_contacts.csv', :type=>"application/csv"#, :x_sendfile=>true
    send_data csv_string, :type => 'text/csv; charset=UTF-8; header=present', :disposition => "attachment; filename=sample_contacts.csv"
  end
  
  protected
    
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
      AnswerSheet.where(survey_id: organization.survey_ids, person_id: people.collect(&:id)).includes(:answers, {:person => :primary_email_address}).each do |answer_sheet|
        @surveys[answer_sheet.person_id] ||= {}
        @surveys[answer_sheet.person_id][answer_sheet.survey] = answer_sheet.completed_at
        
        answers[answer_sheet.person_id] ||= {}
        questions.each do |q|
          answers[answer_sheet.person_id][q.id] = [q.display_response(answer_sheet), answer_sheet.created_at] if q.display_response(answer_sheet).present?
        end
      end
      answers
    end

    def create_contact_from_row(params)
      @organization ||= current_organization
      Person.transaction do
        params[:person] ||= {}
        params[:person][:email_address] ||= {}
        params[:person][:phone_number] ||= {}

        @person, @email, @phone = create_person(params[:person])
        if @person.save

          create_contact_at_org(@person, @organization)
          if params[:assign_to_me] == 'true'
            ContactAssignment.where(person_id: @person.id, organization_id: @organization.id).destroy_all
            ContactAssignment.create!(person_id: @person.id, organization_id: @organization.id, assigned_to_id: current_person.id)
          end
          return
        end
      end
    end
end
