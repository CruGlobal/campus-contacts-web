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
    url = request.url.split('?')
    @attr = url.size > 1 ? url[1] : ''
    fetch_all_contacts
  
    respond_to do |wants|
      wants.html do
        @roles = Hash[OrganizationalRole.active.where(organization_id: @organization.id, person_id: @people.collect(&:id)).map {|r| [r.person_id, r]}]
        @assignments = ContactAssignment.includes(:assigned_to).where(person_id: @people.collect(&:id), organization_id: @organization.id).group_by(&:person_id)
        @answers = generate_answers(@people, @organization, @questions)
      end
      wants.csv do
        @roles = Hash[OrganizationalRole.active.where(organization_id: @organization.id, person_id: @all_people.collect(&:id)).map {|r| [r.person_id, r]}]
        @all_answers = generate_answers(@all_people, @organization, @questions)
        out = ""
        @questions.select! { |q| !%w{first_name last_name phone_number email}.include?(q.attribute_name) }
        CSV.generate(out) do |rows|
          rows << [t('contacts.index.first_name'), t('contacts.index.last_name'), t('general.status'), t('general.assigned_to'), t('general.gender'), t('contacts.index.phone_number'), t('people.index.email')] + @questions.collect {|q| q.label} + [t('contacts.index.last_survey')]
          @all_people.each do |person|
            if @roles[person.id]
              answers = [person.first_name, person.last_name, @roles[person.id].followup_status.to_s.titleize, person.assigned_tos_by_org(current_organization).collect{|a| Person.find(a.assigned_to_id).name}.join(','), person.gender.to_s.titleize, person.pretty_phone_number, person.email]
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
              answers << I18n.l(dates.sort.reverse.last, format: :date) if dates.present?
              rows << answers
            end
          end
        end
        filename = @organization.to_s
        send_data(out, :filename => "#{filename} - Contacts.csv", :type => 'application/csv' )
      end
    end
    @filtered_people = @all_people.find_all{|person| !@people.include?(person) }
    @all_people_with_phone_number = @all_people.find_all{|person| person.pretty_phone_number.present? }
    @all_people_with_email = @all_people.find_all{|person| person.email.present? }
  end
  
  def contacts_all
    fetch_all_contacts
    @filtered_people = @all_people.find_all{|person| !@people.include?(person) }
    render partial: "contacts/contacts_all"
  end

  def search_by_name_and_email
    
    @people = params[:include_archived] ?
      current_organization.people.search_by_name_or_email(params[:term].strip, current_organization.id).uniq :
      current_organization.people.search_by_name_or_email(params[:term].strip, current_organization.id).uniq.archived_not_included

    respond_to do |wants|
      wants.json { render text: @people.collect{|person| {"label" => "#{person.name} (#{person.email})", "id" => person.id}}.to_json }
    end
  end
  
  def mine
    url = request.url.split('?')
    @attr = url.size > 1 ? url[1] : ''
    fetch_mine
    if params[:status] == 'completed'
      @all_people = @all_people.where("organizational_roles.followup_status = 'completed'")
    elsif params[:status] != 'all'
      @all_people = @all_people.where("organizational_roles.followup_status <> 'completed'")
    end
    @people = Kaminari.paginate_array(@all_people).page(params[:page])
  end
  
  def mine_all
    mine
    @filtered_people = @all_people.find_all{|person| !@people.include?(person) }
    render :partial => 'contacts/mine_all'
  end
  
  def update
    @person = Person.find(params[:id])
    authorize!(:update, @person)
    
    @person.update_attributes(params[:person]) if params[:person]

    update_survey_answers if params[:answers].present?
    @person.update_date_attributes_updated
    if @person.valid? && (!@answer_sheet || (@answer_sheet.person.valid? && (!@answer_sheet.person.primary_phone_number || @answer_sheet.person.primary_phone_number.valid?)))
      respond_to do |wants|
        params[:update] = 'true'
        wants.js
        wants.html { redirect_to survey_response_path(@person) }
      end
    else
      redirect_to survey_response_path(params[:id])
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
    leaders = current_organization.leaders.where(id: to_ids)

    if leaders.present?
      ContactsMailer.enqueue.reminder(leaders.collect(&:email).compact, current_person.email, params[:subject], params[:body])
    end
    render nothing: true
  end
  
  protected
  
    def fetch_all_contacts
      @header = nil
      @style = params[:edit] ? 'display:true' : 'display:none'
      @saved_contact_search = @person.user.saved_contact_searches.find(:first, :conditions => "full_path = '#{request.fullpath.gsub(I18n.t('contacts.index.edit_true'),"")}'") || SavedContactSearch.new
      @organization = current_organization # params[:org_id].present? ? Organization.find_by_id(params[:org_id]) : 
      unless @organization
        redirect_to user_root_path, error: t('contacts.index.which_org')
        return false
      end
      @surveys = @organization.surveys
      @all_questions = @organization.all_questions.flatten.uniq
      @questions = @organization.all_questions.where("survey_elements.hidden" => false).flatten.uniq
      @hidden_questions = @organization.all_questions.where("survey_elements.hidden" => true).flatten.uniq

      params[:assigned_to] = 'all' if !params[:assigned_to].present?# make 'all default' on 'all contacts' tab instead of 'unassigned'
      
      org_ids = params[:subs] == 'true' ? current_organization.self_and_children_ids : current_organization.id
      
      @people_scope = Person.where('organizational_roles.organization_id' => org_ids).where("organizational_roles.role_id <> #{Role::CONTACT_ID} OR (organizational_roles.role_id = #{Role::CONTACT_ID} AND organizational_roles.followup_status <> 'do_not_contact')").includes(:organizational_roles_including_archived)
      
      @people_scope = @people_scope.where(id: @people_scope.archived_not_included.collect(&:id)) if params[:include_archived].blank? && params[:archived].blank?
      
      @people_scope = @people_scope.includes(:primary_phone_number, :primary_email_address)
      sort_by = ['lastName asc', 'firstName asc']
      
      if params[:dnc] == 'true'
        @people = @organization.dnc_contacts
        @header = I18n.t('contacts.index.dnc')
      elsif params[:completed] == 'true'
        @header = I18n.t('contacts.index.completed')
        @people = @organization.completed_contacts
      elsif params[:archived].present? && params[:archived] == 'true'
        @header = I18n.t('contacts.index.archived')
        @people = Person.where(id: current_organization.people.archived(current_organization.id).collect(&:id))
      elsif params[:role] || (params[:search] && params[:role])
        if @role = Role.find(params[:role])
          @people = @people_scope.where('organizational_roles.role_id = ? AND organizational_roles.organization_id = ? AND organizational_roles.deleted = 0', @role.id, current_organization.id)
          if params[:include_archived].present? && params[:include_archived] == 'true'
            @people = @people.select("people.*, roles.*")
                      .joins("LEFT JOIN organizational_roles AS org_roles ON 
                        org_roles.person_id = people.id")
                      .joins("INNER JOIN roles ON roles.id = org_roles.role_id")
                      .where("org_roles.organization_id" => current_organization.id)
                      .where("roles.id = #{@role.id}")
                      sort_by.unshift("roles.id").uniq
          else
            @people = @people.select("people.*, roles.*")
                      .joins("LEFT JOIN organizational_roles AS org_roles ON 
                        org_roles.person_id = people.id")
                      .joins("INNER JOIN roles ON roles.id = org_roles.role_id")
                      .where("org_roles.archive_date" => nil, "org_roles.organization_id" => current_organization.id) 
                      .where("roles.id = #{@role.id}")
                      sort_by.unshift("roles.id").uniq
                    
          end
          @header = params[:search] ? I18n.t('contacts.index.matching_seach') : @role.i18n
        end
      elsif params[:search]
        @header = I18n.t('contacts.index.matching_seach')
        @people = @people_scope
      else
        params[:assigned_to] = nil if params[:assigned_to].blank?
        if params[:assigned_to]
          case params[:assigned_to]
          when 'all'
            if params[:include_archived].present? && params[:include_archived] == 'true'
              @people = @organization.contacts_with_archived
            else
              @people = @organization.contacts
            end
          when 'unassigned'
            @people = @organization.unassigned_contacts
            @header = I18n.t('contacts.index.unassigned')
          when 'progress'
            @people = @organization.inprogress_contacts
            @header = I18n.t('contacts.index.in_progress')
          when 'no_activity'
            @people = @organization.no_activity_contacts
            @header = I18n.t('contacts.index.no_activity')
          when 'friends'
            @people = current_person.contact_friends(@organization)
            @header = I18n.t('contacts.index.friend_responses')
          when *Rejoicable::OPTIONS
            @people = @organization.send(:"#{params[:assigned_to]}_contacts")
            @header = I18n.t("rejoicables.#{params[:assigned_to]}")
          else
            if params[:assigned_to].present? && @assigned_to = Person.find_by_id(params[:assigned_to])
              @header = I18n.t('contacts.index.responses_assigned_to', assigned_to: @assigned_to)
              @people = Person.includes(:assigned_tos).where('contact_assignments.organization_id' => @organization.id, 'contact_assignments.assigned_to_id' => @assigned_to.id)
            end
          end
        end
        @people ||= Person.where("1=0")
      end
      unless @people.arel.to_sql.include?('JOIN organizational_roles')
        @header = "#{Role.find(params[:role]).i18n}" if params[:role].present?
      end
      if params[:q] && params[:q][:s].include?('answer_sheets')
        @people = current_organization.contacts.get_and_order_by_latest_answer_sheet_answered(params[:q][:s], current_organization.id)
      end
      if params[:q] && params[:q][:s].include?('followup_status')
        @people = current_organization.contacts.order_by_followup_status(params[:q][:s])
      end
      if params[:survey].present?
        @people = @people.joins(:answer_sheets).where("answer_sheets.survey_id" => params[:survey])
      end
      if params[:first_name].present?
        v = params[:first_name].strip
        term = (v.first == v.last && v.last == '"') ? v[1..-2] : "%#{v}%"
        @people = @people.where("first_name like ?", term)
      end
      if params[:last_name].present?
        v = params[:last_name].strip
        term = (v.first == v.last && v.last == '"') ? v[1..-2] : "%#{v}%"
        @people = @people.where("last_name like ?", term)
      end
      if params[:email].present?
        v = params[:email].strip
        term = (v.first == v.last && v.last == '"') ? v[1..-2] : "%#{v}%"
        @people = @people.includes(:primary_email_address).where("email_addresses.email like ?", term)
      end
      if params[:phone_number].present?
        v = PhoneNumber.strip_us_country_code(params[:phone_number])
        term = (v.first == v.last && v.last == '"') ? v[1..-2] : "%#{v}%"
        @people = @people.where("phone_numbers.number like ?", term)
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
            if question.is_a?(TextField)
              # do an exact search if the term is wrapped with quotes
              term = (v.first == v.last && v.last == '"') ? v[1..-2] : "%#{v}%"
            else
              term = v
            end

            # If this question is assigned to a column, we need to handle that differently
            if question.object_name.present?
              table_name = case question.object_name
                           when 'person'
                             case question.attribute_name
                             when 'email'
                               @people = @people.includes(:email_addresses).where("#{EmailAddress.table_name}.email like ?", term) unless v.strip.blank?
                             when 'phone_number'
                               @people = @people.includes(:phone_numbers).where("#{PhoneNumber.table_name}.number like ?", term) unless v.strip.blank?
                             else
                               @people = @people.where("#{Person.table_name}.#{question.attribute_name} like ?", term) unless v.strip.blank?
                             end
                           end
            else
              unless v.strip.blank?
                @people = @people.joins(:answer_sheets)
                @people = @people.joins("INNER JOIN `answers` as a#{q_id} ON a#{q_id}.`answer_sheet_id` = `answer_sheets`.`id`").where("a#{q_id}.question_id = ? AND a#{q_id}.value like ?", q_id, term)
              end
            end
          else
            conditions = ["#{Answer.table_name}.question_id = ?", q_id]
            answers_conditions = []
            v.each do |k1, v1| 
              unless v1.strip.blank?
                if question.is_a?(TextField)
                  answers_conditions << "#{Answer.table_name}.value like ?"
                  conditions << (v1.first == v1.last && v1.last == '"') ? v1[1..-2] : "%#{v1}%"
                else
                  answers_conditions << "#{Answer.table_name}.value = ?"
                  conditions << v1
                end
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

      if params[:search_type].present? && params[:search_type] == "basic"
        @people = @people.search_by_name_or_email(params[:query], current_organization.id)
      end


      @q = Person.where('1 <> 1').search(params[:q]) # Fake a search object for sorting
      # raise @q.sorts.inspect
      
      @people = @people.includes(:primary_phone_number, :primary_email_address).order(params[:q] && params[:q][:s] ? params[:q][:s].gsub('answer_sheets','ass') : ['last_name, first_name']).group('people.id')
      
      @all_people = @people
      @people_for_labels = Person.people_for_labels(current_organization)
      @people = @people.includes(:organizational_roles)
      @people = @people.page(params[:page])
    
    end
  
    def fetch_mine
      #@all_people = Person.order('last_name, first_name').includes(:assigned_tos, :organizational_roles).where('contact_assignments.organization_id' => current_organization.id, 'contact_assignments.assigned_to_id' => current_person.id, 'organizational_roles.organization_id' => current_organization.id, 'organizational_roles.role_id' => Role::CONTACT_ID)
      @all_people = Person.order('last_name, first_name').includes(:assigned_tos, :organizational_roles).where('contact_assignments.organization_id' => current_organization.id, 'contact_assignments.assigned_to_id' => current_person.id)
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
      AnswerSheet.where(survey_id: organization.survey_ids, person_id: people.collect(&:id)).includes(:answers, {:person => :primary_email_address}).each do |answer_sheet|
        @surveys[answer_sheet.person_id] ||= {}
        @surveys[answer_sheet.person_id][answer_sheet.survey] = answer_sheet.completed_at
        
        answers[answer_sheet.person_id] ||= {}
        questions.each do |q|
          answers[answer_sheet.person_id][q.id] = [q.display_response(answer_sheet), answer_sheet.updated_at]# if q.display_response(answer_sheet).present?# or (q.attribute_name == "email" and q.object_name == 
        end
      end
      answers
    end

end
