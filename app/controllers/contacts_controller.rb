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

    respond_to do |wants|
      wants.html do
        fetch_contacts(false)
        @assignments = ContactAssignment.includes(:assigned_to).where(person_id: @people.pluck('people.id'), organization_id: @organization.id).group_by(&:person_id)
        @answers = generate_answers(@people, @organization, @questions, @surveys)
      end

      wants.csv do
        fetch_contacts(true)
        @roles = Hash[OrganizationalRole.active.where(organization_id: @organization.id, person_id: @all_people.collect(&:id)).map {|r| [r.person_id, r] if r.role_id == Role::CONTACT_ID }]
        @all_answers = generate_answers(@all_people, @organization, @questions, @surveys)
        @questions.select! { |q| !%w{first_name last_name phone_number email}.include?(q.attribute_name) }
        filename = @organization.to_s
        @all_people = @all_people.where('people.id IN (:ids)', ids: params[:only_ids].split(',')) if params[:only_ids].present?
        csv = ContactsCsvGenerator.generate(@roles, @all_answers, @questions, @all_people, @organization)
        send_data(csv, :filename => "#{filename} - Contacts.csv", :type => 'application/csv' )
      end
    end
  end

  def contacts_all
    fetch_contacts(true)
    @filtered_people = @all_people.find_all{|person| !@people.include?(person) }
    render partial: "contacts/contacts_all"
  end

  def search_by_name_and_email
    @people = params[:include_archived] ?
      current_organization.people.search_by_name_or_email(params[:term].strip, current_organization.id).uniq :
      current_organization.people.search_by_name_or_email(params[:term].strip, current_organization.id).uniq.archived_not_included
    respond_to do |wants|
      wants.json { render text: @people.collect{|person| {"label" => person.name, "email" => person.email.downcase, "id" => person.id}}.to_json }
    end
  end

  def auto_suggest_send_email
    term = params[:q].try(:strip).downcase

		# Search - enable "All contacts" for admins
		all_contacts = is_admin? && term =~ /all/ ? [{:name=>"All (#{current_organization.all_people.count})", :id=>"ALL-PEOPLE"}] : []

		# Search Roles
		roles = current_organization.role_search(term)
		get_and_merge_unfiltered_people
		roles_results = roles.collect{|p| {name: "#{p.name} (#{@people_unfiltered.where("role_id = ?", p.id).count})", id: "ROLE-#{p.id}"}}

		# Search Groups
		groups = current_organization.group_search(term)
		groups_results = groups.collect{|p| {name: "#{p.name} (#{p.group_memberships.count})", id: "GROUP-#{p.id}"}}

		# Search People
		people = current_organization.people.email_search(term, current_organization.id).uniq
		people = people.archived_not_included unless params[:include_archived].present?
		people_results = people.collect{|p| {name: "#{p.name} - #{p.email.downcase}", id: p.id.to_s}}

		@results = all_contacts + roles_results + groups_results + people_results

		respond_to do |format|
		  format.json { render json: @results.to_json }
		end
  end

  def auto_suggest_send_text
    term = params[:q].try(:strip).downcase

		# Search - enable "All contacts" for admins
		all_contacts = is_admin? && term =~ /all/ ? [{:name=>"All (#{current_organization.all_people.count})", :id=>"ALL-PEOPLE"}] : []

		# Search Roles
		roles = current_organization.role_search(term)
		get_and_merge_unfiltered_people
		roles_results = roles.collect{|p| {name: "#{p.name} (#{@people_unfiltered.where("role_id = ?", p.id).count})", id: "ROLE-#{p.id}"}}

		# Search Groups
		groups = current_organization.group_search(term)
		groups_results = groups.collect{|p| {name: "#{p.name} (#{p.group_memberships.count})", id: "GROUP-#{p.id}"}}

		# Search People
    people = current_organization.people.phone_search(term, current_organization.id).uniq
    people = people.archived_not_included unless params[:include_archived].present?
		people_results = people.collect{|p| {name: "#{p.name} - #{p.primary_phone_number.pretty_number}", id: p.id.to_s}}

		@results = all_contacts + roles_results + groups_results + people_results

		respond_to do |format|
		  format.json { render json: @results.to_json }
		end
  end

  def mine
    params[:status] ||= 'in_progress'
    url = request.url.split('?')
    @attr = url.size > 1 ? url[1] : ''
    @organization = current_organization
    fetch_mine

    @all_contacts = @all_people
    @inprogress_contacts = @all_people.where("organizational_roles.followup_status <> 'completed'")
    @completed_contacts = @all_people.where("organizational_roles.followup_status = 'completed'")
    if params[:status] == 'completed'
      @all_people = @completed_contacts
    elsif params[:status] == 'in_progress'
      @all_people = @inprogress_contacts
    end

    @q = @all_people.where('1 <> 1').search(params[:q])

    order = params[:q].present? ? params[:q][:s] : "people.last_name ASC, people.first_name ASC";
	  @all_people = @all_people.order("#{order}")
    @people = @all_people.group('people.id').page(params[:page])
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

    # birth_date validation
    @valid_date = true
    if params[:answers]
      params[:answers].each do |survey,answers|
        answers.each do |key,val|
          if val.present? && date_question = Element.find_by_id(key.to_i)
            @person.birth_date = val if date_question.attribute_name == 'birth_date'
            @person.graduation_date = val if date_question.attribute_name == 'graduation_date'
            @person.save if ['birth_date','graduation_date'].include?(date_question.attribute_name)
            unless @person.valid?
              @valid_date = false
              break
            end
          end
        end
      end if @valid_date
    end
    update_survey_answers if params[:answers]
    @person.update_date_attributes_updated

    unless @valid_date
      redirect_to edit_survey_response_path(@person), notice: @person.errors.full_messages.first
    else
      if @person.valid? && (!@answer_sheet || @answer_sheet.valid_person?)
        respond_to do |wants|
          params[:update] = 'true'
          wants.js
          wants.html { redirect_to survey_response_path(@person) }
        end
      else
        redirect_to edit_survey_response_path(params[:id])
      end
    end
  end

  def show
    redirect_to person_path(params[:id])
  end

  def edit
    redirect_to survey_response_path(params[:id])
  end

  def create
    params[:answers].each do |answer|
      answers = []
      fields = answer[1]
      if fields.is_a?(Hash)
        # Read birth_date question from non-predefined survey
        answers.each do |key,val|
          if val.present? && date_question = Element.find_by_id(key.to_i)
            @person.birth_date = val if date_question.attribute_name == 'birth_date'
            @person.graduation_date = val if date_question.attribute_name == 'graduation_date'
            break unless @person.valid?
          end
        end
      else
        # Read birth_date question from predefined survey
        question_id = answers[0]
        if fields.present? && date_question = Element.find_by_id(question_id.to_i)
          @person.birth_date = fields if date_question.attribute_name == 'birth_date'
          @person.graduation_date = fields if date_question.attribute_name == 'graduation_date'
          break unless @person.valid?
        end
      end
    end if params[:answers]

    @organization = current_organization
    create_contact

  end

  def destroy
    contact = Person.find(params[:id])
    authorize! :manage, contact
    current_organization.remove_person(contact)

    render :nothing => true
  end

  def bulk_destroy
    authorize! :manage, current_organization
    Person.find(params[:ids]).each do |contact|
      current_organization.remove_person(contact)
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

  def show_hidden_questions
    @organization = current_organization
    @all_questions = @organization.questions
    @predefined_survey = Survey.find(APP_CONFIG['predefined_survey'])
    excepted_predefined_fields = ['first_name','last_name','gender','phone_number']
    @predefined_questions = @predefined_survey.questions.where("attribute_name NOT IN (?)", excepted_predefined_fields)
    @questions = (@all_questions.where("survey_elements.hidden" => false) + @predefined_questions.where(id: current_organization.settings[:visible_predefined_questions])).uniq
    @hidden_questions = ((@predefined_questions + @all_questions) - @questions).flatten.uniq
  end

  def show_search_hidden_questions
    show_hidden_questions
    @search_hidden_questions = @hidden_questions
  end

  def display_sidebar
    @organization = current_organization

    # Saved Search
    @all_saved_contact_searches = current_user.saved_contact_searches.where('organization_id = ?', current_organization.id)

    get_and_merge_unfiltered_people
  end
  
  def check_email
    email = params[:email]
    fname = params[:fname]
    lname = params[:lname]
    
    code = '100'
    if email.present? && fname.present? && lname.present?
      if fetched_email = EmailAddress.find_by_email(email) || User.find_by_username(email) || User.find_by_email(email)
        person = fetched_email.person
        if person.present?
          if person.first_name.downcase.strip == fname.downcase.strip && person.last_name.downcase.strip == lname.downcase.strip
            if person.organizational_roles.where(:organization_id => current_organization).first
              code = '201'
            end
          else
            code = '202'
          end
        end
      end
    else
      code = '203'
    end  
    render :text => code
  end

  def search_locate_contact
    firstname = params[:fname]
    lastname = params[:lname]
    email = params[:email]
    @manage_org_ids = current_person.organizational_roles.find_admin_or_leader
    if @manage_org_ids
      get_all_people = Person.where('organizational_roles.organization_id IN (?)', @manage_org_ids.collect(&:organization_id)).joins(:organizational_roles).uniq
      if get_all_people.count > 0
        query = ""
        if firstname.present?
          query += " first_name LIKE '#{manage_wild_card(firstname.strip)}' "
        end
        if lastname.present?
          query += " AND " if query.length > 0
          query += " last_name LIKE '#{manage_wild_card(lastname.strip)}' "
        end
        if email.present?
          query += " AND " if query.length > 0
          query += " email LIKE '#{manage_wild_card(email.strip)}' "
        end
        @filtered_contact = get_all_people.joins(:email_addresses).where(query) if query.length > 0
      end
    end
  end
  
  protected
    def fetch_contacts(load_all = false)
      # Load Saved Searches, Surveys & Questions
      initialize_variables
      update_fb_friends if current_person.friends.count == 0

      # Fix old search variable from saved searches
      handle_old_search_variable if params[:search] == "1"

      # Get people
      build_people_scope
      get_and_merge_unfiltered_people unless params[:dnc] == 'true'

      # Filter results
      filter_archived_only if params[:archived].present?
      filter_by_label if params[:role].present?
      filter_by_search if params[:do_search].present?

      # Sort & Limit Results
      sort_people(params[:page], load_all)
    end

    def update_fb_friends
      fb_auth = current_user.authentications.first
      current_person.update_friends(fb_auth) if fb_auth.present?
    end

    def initialize_variables
      # Layout
      @header = nil
      @style = params[:edit] ? 'display:block' : 'display:none'

      # Organization
      @organization = Organization.includes(:surveys, :groups, :questions).find(current_organization.id)

      # Saved Search
      @saved_contact_search = current_user.saved_contact_searches.where("full_path = '#{request.fullpath.gsub(I18n.t('contacts.index.edit_true'),"")}'").first || SavedContactSearch.new

      # Surveys & Questions
      @surveys = @organization.surveys
      @all_questions = @organization.questions
      excepted_predefined_fields = ['first_name','last_name','gender','phone_number']
      @predefined_survey = Survey.find(APP_CONFIG['predefined_survey'])
      @predefined_questions = @predefined_survey.questions.where("attribute_name NOT IN (?)", excepted_predefined_fields)
      @questions = (@all_questions.where("survey_elements.hidden" => false) + @predefined_questions.where(id: current_organization.settings[:visible_predefined_questions])).uniq

      # Labels
      @people_for_labels = Person.people_for_labels(current_organization)
    end

    def build_people_scope
      params[:assigned_to] = 'all' if params[:role].present?
      if params[:assigned_to].present?
        case params[:assigned_to]
        when 'all'
          if params[:include_archived].present? && params[:include_archived] == 'true'
            @people_scope = @organization.all_people_with_archived
          else
            @people_scope = @organization.all_people
          end
        when 'unassigned'
          if params[:include_archived].present? && params[:include_archived] == 'true'
            @people_scope = @organization.unassigned_contacts_with_archived
          else
            @people_scope = @organization.unassigned_contacts
          end
          @header = I18n.t('contacts.index.unassigned')
        when 'no_activity'
          @people_scope = @organization.no_activity_contacts
          @header = I18n.t('contacts.index.no_activity')
        when 'friends'
          @people_scope = current_person.contact_friends(@organization)
          @header = I18n.t('contacts.index.friend_responses')
        when *Rejoicable::OPTIONS
          @people_scope = @organization.send(:"#{params[:assigned_to]}_contacts")
          @header = I18n.t("rejoicables.#{params[:assigned_to]}")
        else
          if params[:assigned_to].present? && @assigned_to = Person.find_by_id(params[:assigned_to])
            @people_scope = @organization.all_people_with_archived.joins(:assigned_tos).where('contact_assignments.organization_id' => @organization.id, 'contact_assignments.assigned_to_id' => @assigned_to.id)
            @header = I18n.t('contacts.index.responses_assigned_to', assigned_to: @assigned_to)
          end
        end
      elsif params[:dnc] == 'true'
        @people_scope = @organization.dnc_contacts
        @header = I18n.t('contacts.index.dnc')
      elsif params[:completed] == 'true'
        @header = I18n.t('contacts.index.completed')
        @people_scope = @organization.completed_contacts
      end
      @people_scope ||= current_organization.people
    end

    def get_and_merge_unfiltered_people
      org_ids = params[:subs] == 'true' ? current_organization.self_and_children_ids : current_organization.id
      @people_unfiltered = Person.where('organizational_roles.organization_id' => org_ids)
                                 .where("organizational_roles.followup_status <> 'do_not_contact' OR organizational_roles.followup_status IS NULL")
                                 .joins(:organizational_roles_including_archived)

      if params[:include_archived].blank? && params[:archived].blank?
        @people_unfiltered = @people_unfiltered.where('organizational_roles.archive_date' => nil)
      end
      @people_scope = @people_scope.merge(@people_unfiltered) if @people_scope.present?
    end

    def filter_archived_only
      @header = I18n.t('contacts.index.archived')
      @people_scope = @people_scope.where(id: current_organization.people.archived(current_organization.id).collect(&:id))
    end

    def handle_old_search_variable
      params[:search] = nil
      params[:do_search] = "1"
    end

    def filter_by_label
    	params[:role] = [params[:role]] unless params[:role].is_a?(Array)
      if @roles = Role.select("id, name, i18n").where("id IN (?)",params[:role])
        if params[:do_search].present?
          @header = I18n.t('contacts.index.matching_seach')
        else
          @header = @roles.collect{|desc| (desc.i18n.present? ? desc.i18n : desc.name).try('titleize')}.to_sentence
        end

      	if params[:role_tag].present? && params[:role_tag].to_i == Role::ALL_SELECTED_LABEL[1]
					valid_ids = []
			  	@roles.collect(&:id).each do |role|
      			valid_ids << @people_scope.where('organizational_roles.role_id IN (?)', [role]).collect(&:id)
					end

					filtered_ids = []
					valid_ids.each do |person_ids|
						filtered_ids = filtered_ids.present? ? filtered_ids &= person_ids : person_ids
					end

					@people_scope = @people_scope.where("people.id IN (?)", filtered_ids)
      	else
        	@people_scope = @people_scope.where("organizational_roles.role_id IN (?)", @roles.collect(&:id))
      	end

        if !params[:include_archived].present? && !params[:include_archived] == 'true'
          @people_scope = @people_scope.where("organizational_roles.archive_date" => nil)
        end
      end
    end

    def filter_by_search
      @header = I18n.t('contacts.index.matching_seach')
      if params[:survey].present?
        @people_scope = @people_scope.joins(:answer_sheets).where("answer_sheets.survey_id" => params[:survey])
      end
	    if params[:survey_updated_from].present? && params[:survey_updated_to].present?
	      @people_scope = @people_scope.find_by_survey_updated_by_daterange(format_date_for_search(params[:survey_updated_from]), format_date_for_search(params[:survey_updated_to]), current_organization.id)
	    end
      if params[:first_name].present?
        v = params[:first_name].strip
        term = (v.first == v.last && v.last == '"') ? v[1..-2] : "%#{v}%"
        @people_scope = @people_scope.where("first_name like ?", term)
      end
      if params[:last_name].present?
        v = params[:last_name].strip
        term = (v.first == v.last && v.last == '"') ? v[1..-2] : "%#{v}%"
        @people_scope = @people_scope.where("last_name like ?", term)
      end
      if params[:email].present?
        v = params[:email].strip
        term = (v.first == v.last && v.last == '"') ? v[1..-2] : "%#{v}%"
        @people_scope = @people_scope.joins(:email_addresses).where("email_addresses.email like ?", term)
      end
      if params[:phone_number].present?
        v = PhoneNumber.strip_us_country_code(params[:phone_number])
        term = (v.first == v.last && v.last == '"') ? v[1..-2] : "%#{v}%"
        @people_scope = @people_scope.joins(:phone_numbers).where("phone_numbers.number like ?", term)
      end
      if params[:gender].present?
        @people_scope = @people_scope.where("gender = ?", params[:gender].strip)
      end
      if params[:status].present?
        @people_scope = @people_scope.where("organizational_roles.followup_status" => params[:status].strip)
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

						if term =~ /^([1-9]|0[1-9]|1[012])\/([1-9]|0[1-9]|[12][1-9]|3[01])\/(19|2\d)\d\d$/
							begin
								get_date = term.split('/')
								term = Date.parse("#{get_date[2]}-#{get_date[0]}-#{get_date[1]}").strftime("%Y-%m-%d")
							rescue
							end
						end

            # If this question is assigned to a column, we need to handle that differently
            if question.object_name.present?
              table_name = case question.object_name
              when 'person'
                case question.attribute_name
                when 'email'
                  @people_scope = @people_scope.joins(:email_addresses).where("#{EmailAddress.table_name}.email like ?", term) unless v.strip.blank?
                when 'phone_number'
                  @people_scope = @people_scope.joins(:phone_numbers).where("#{PhoneNumber.table_name}.number like ?", term) unless v.strip.blank?
                when 'address1', 'city', 'state', 'country', 'dorm', 'room', 'zip'
                  @people_scope = @people_scope.joins(:current_address).where("#{Address.table_name}.#{question.attribute_name} like ?", term) unless v.strip.blank?
                when 'graduation_date'
                	table = "#{Person.table_name}.#{question.attribute_name}"
	              	where_query = term =~ /^\d{4}$/ ? "YEAR(#{table})" : table
									@people_scope = @people_scope.where("#{where_query} like ?", term) unless v.strip.blank?
                else
									@people_scope = @people_scope.where("#{Person.table_name}.#{question.attribute_name} like ?", term) unless v.strip.blank?
                end
              end
            else
              unless v.strip.blank?
                @people_scope = @people_scope.joins(:answer_sheets)
                @people_scope = @people_scope.joins("INNER JOIN `answers` as a#{q_id} ON a#{q_id}.`answer_sheet_id` = `answer_sheets`.`id`").where("a#{q_id}.question_id = ? AND a#{q_id}.value like ?", q_id, term)
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
              @people_scope = @people_scope.joins(:answer_sheets => :answers).where(conditions)
            end
          end
        end
      end
      if params[:search_type].present? && params[:search_type] == "basic"
        @people_scope = @people_scope.search_by_name_or_email(params[:query], current_organization.id)
      end
    end

    def sort_people(page = 1, fetch_all = false)
      @q = Person.where('1 <> 1').search(params[:search]) # Fake a search object for sorting
      if params[:search].present?
        sort_query = params[:search][:meta_sort].gsub('.',' ')
        if sort_query.include?('last_survey')
	        @people_scope = @people_scope.get_and_order_by_latest_answer_sheet_answered(sort_query, current_organization.id)
		    end

		    if sort_query.include?('followup_status')
		    	@people_scope = @people_scope.order_by_followup_status(sort_query)
		    end

		    if sort_query.include?('phone_number')
		    	@people_scope = @people_scope.order_by_primary_phone_number(sort_query)
		    end

	    	if ['role_id','last_name','first_name','gender'].any?{ |i| sort_query.include?(i) }
					order_query = sort_query.gsub('role_id','organizational_roles.role_id')
																	.gsub('gender','ISNULL(people.gender), people.gender')
																	.gsub('first_name', 'people.first_name')
																	.gsub('last_name', 'people.last_name')
				end
      else
      	order_query = "people.last_name asc, people.first_name asc"
      end
      if fetch_all
        @all_people = @people_scope.order(order_query).group('people.id')
        @people = @all_people.page(page)
      else
        @people = @people_scope.order(order_query).group('people.id').page(page)
      end
    end

    def fetch_mine
      @all_people = Person.includes(:assigned_tos, :organizational_roles).where('contact_assignments.organization_id' => current_organization.id, 'organizational_roles.organization_id' => current_organization.id, 'contact_assignments.assigned_to_id' => current_person.id, 'organizational_roles.role_id' => Role::CONTACT_ID).uniq
    end

    def get_person
      @person = user_signed_in? ? current_user.person : Person.new
    end

    def authorize
      authorize! :manage_contacts, current_organization
    end

    def generate_answers(people, organization, questions, surveys = nil)
      answers = {}
      people_ids = people.pluck('people.id')
      survey_ids = surveys.present? ? surveys.collect(&:id) : organization.survey_ids
      people_ids.each do |id|
        answers[id] = {}
      end
      @surveys = {}
      AnswerSheet.where(survey_id: survey_ids, person_id: people_ids).includes({:person => :primary_email_address}).each do |answer_sheet|
        @surveys[answer_sheet.person_id] ||= {}
        @surveys[answer_sheet.person_id][answer_sheet.survey] = answer_sheet.completed_at

        answers[answer_sheet.person_id] ||= {}
        questions.each do |q|
          answers[answer_sheet.person_id][q.id] = [q.display_response(answer_sheet), answer_sheet.updated_at] if q.display_response(answer_sheet).present?# or (q.attribute_name == "email" and q.object_name ==
        end
      end
      answers
    end

end
