require 'contact_actions'
class Api::ContactsController < ApiController
  include ContactActions
  oauth_required scope: "contacts"
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?, :get_organization, :get_api_json_header
  
  def search_1
    @keywords = get_keywords
    json_output = []
    unless (@keywords.empty? || !params[:term].present?)
      @surveys = @keywords.collect(&:survey)
      @people = Person.who_answered(@surveys).where('CONCAT(`ministry_person`.`firstName`," ", `ministry_person`.`lastName`) LIKE ? OR `ministry_person`.`lastName` LIKE ? OR CONCAT(`ministry_person`.`preferredName`," ", `ministry_person`.`lastName`) LIKE ?',"%#{params[:term]}%","%#{params[:term]}%","%#{params[:term]}%")
      @people = paginate_filter_sort_people(@people,@organization)      
      json_output = @people.collect {|person|  { person: person.to_hash_basic(@organization)}}
    end
    final_output = Rails.env.production? ? json_output.to_json : JSON::pretty_generate(json_output)
    render json: final_output
  end
  
  def index_1
    @keywords = get_keywords
    json_output = []
    @surveys = @keywords.collect(&:survey)
    @people = @organization.all_contacts#.order('lastName, firstName')
    @people = paginate_filter_sort_people(@people, @organization)
    json_output = @people.collect {|person| {person: person.to_hash_basic(@organization)}}
    final_output = Rails.env.production? ? json_output.to_json : JSON::pretty_generate(json_output)
    render json: final_output
  end
  
  def index_2
    @people = @organization.all_contacts
    @people = limit_and_offset_object(@people)
    @people = @people.includes(:contact_assignments).includes(:organizational_roles)
    
    # Filter the response
    @filters = {}
    if params[:filters].present?   
      # Build, format, and sanitize filters hash
      params[:filters].each do |key, value|
        if value.strip.length > 0
          val = value.split('|').collect { |i| i = i.strip };
          val.length == 1 ? @filters[key] = val.first :  @filters[key] = val
        end
      end
      
      # Built In Filters
      if @filters.key? 'assigned_to'
        if @filters['assigned_to'] == 'none'
          @people = restrict_to_unassigned_people(@people, @organization)
        else
          val = @filters['assigned_to']
          if (@filters['assigned_to'].kind_of?(Array))
            val = @filters['assigned_to'].first
          end
          if (val == val.to_i.to_s && val.to_i > 0)  
            @people = @people.joins(:assigned_tos).where('contact_assignments.organization_id' => @organization.id, 'contact_assignments.assigned_to_id' => val)
          end
        end
      end
      if @filters.key? 'name'
        @people = @people.where('CONCAT(`ministry_person`.`firstName`," ", `ministry_person`.`lastName`) LIKE ? OR `ministry_person`.`lastName` LIKE ? OR CONCAT(`ministry_person`.`preferredName`," ", `ministry_person`.`lastName`) LIKE ?',"%#{@filters['name']}%","%#{@filters['name']}%","%#{@filters['name']}%")
      end
      if @filters.key? 'first_name'
        @people = @people.where("firstName like ? OR preferredName like ?", '%' + @filters['first_name'] + '%', '%' + @filters['first_name'] + '%')
      end
      if @filters.key? 'last_name'
        @people = @people.where("lastName like ?", '%' + @filters['last_name'] + '%')
      end
      if @filters.key? 'email'
        @people = @people.includes(:primary_email_address).where("email_addresses.email like ?", '%' + @filters['email'] + '%')
      end
      if @filters.key? 'phone_number'
        @people = @people.where("phone_numbers.number like ?", '%' + PhoneNumber.strip_us_country_code(@filters['phone_number']) + '%')
      end
      if @filters.key? 'gender'
        @filters['gender'] == 'male' ? gender = 1 : gender = 0
        @people = @people.where("gender = ?", gender)
      end
      if @filters.key? 'status'
        @people = @people.where("organizational_roles.followup_status" => @filters['status'])
      end
      
      # Dynamic Filtering
      @filters.each do |q_id, v|
        if (q_id == q_id.to_i.to_s && q_id.to_i >= 0) #looking for question ids
          question = Element.find(q_id)
          if v.is_a?(String)
            if question.object_name.present?
              table_name = case question.object_name
              when 'person'
                case question.attribute_name
                when 'email'
                  @people = @people.includes(:email_addresses).where("#{EmailAddress.table_name}.email like ?", '%' + v + '%') unless v.blank?
                else
                  @people = @people.where("#{Person.table_name}.#{question.attribute_name} like ?", '%' + v + '%') unless v.blank?
                end
              end
            else
              @people = @people.joins(:answer_sheets)
              @people = @people.joins("INNER JOIN `mh_answers` as a#{q_id} ON a#{q_id}.`answer_sheet_id` = `mh_answer_sheets`.`id`").where("a#{q_id}.question_id = ? AND a#{q_id}.value like ?", q_id, '%' + v + '%') unless v.blank?
            end
          else
            conditions = ["#{Answer.table_name}.question_id = ?", q_id]
            answers_conditions = []
            v.each do |k1, v1| 
              unless v1.blank?
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
    end
    
    # Sorting
    if params[:order_by].present?
      ordering = params[:order_by].split('|').collect { |i| i = i.strip }
      
      ordering.each do |sort|
        order = sort.split(',').collect { |i| i = i.strip }
        on = order.first
        order.length > 1 ? dir = order.second.downcase : dir = 'asc'
        
        if dir != "asc" && dir != "desc"
          dir = 'asc'
        end
        
        case on
        when 'first_name'
          @people = @people.order("`#{Person.table_name}`.`firstName` #{dir}")
        when 'last_name'
          @people = @people.order("`#{Person.table_name}`.`lastName` #{dir}")
        when 'phone'
          @people = @people.includes(:primary_phone_number).order("`#{PhoneNumber.table_name}`.`number` #{dir}")
        when 'email'
          @people = @people.includes(:primary_email_address).order("`#{EmailAddress.table_name}`.`email` #{dir}")
        when 'gender'
          @people = @people.order("`#{Person.table_name}`.`gender` #{dir}")
        when 'status'
          @people = @people.order("`#{OrganizationalRole.table_name}`.`followup_status` #{dir}")
        when 'date_created'
          @people = @people.order("`#{OrganizationalRole.table_name}`.`created_at` #{dir}")
        when 'date_surveyed'
          @people = @people.includes(:answer_sheets).order("`mh_answer_sheets`.`created_at` #{dir}")
        end
      end
    else 
      @people = @people.order("`#{OrganizationalRole.table_name}`.`created_at` desc")
    end
    
    @people = restrict_to_contact_role(@people,@organization)
    
    output = @api_json_header
    output[:contacts] = @people.collect {|person| {person: person.to_hash_basic(@organization)}}

    final_output = Rails.env.production? ? output.to_json : JSON::pretty_generate(output)
    
    render json: final_output
  end
  
  def show_1
    @filled_out_surveys = {}
    @answer_sheets = {}
    @surveys = {}
    @questions = {}
    @filled_out_org_surveys = {}
    @all_questions = []
    @all_survey_ids = []
    json_output = {}
    @people = get_people
    unless @people.empty?
      @people.each do |person|
        @questions[person] = {}
        #get all of the possible question sheets in the request organization
        @surveys = @organization.surveys
        #find all of the answer sheets from this person that belong to this organization
        @answer_sheets[person] = person.answer_sheets.where(survey_id: @surveys)
        #push all of the question sheet ids onto an arroy so we can build the keywords answered by all people in the request
        @all_survey_ids << @answer_sheets[person].collect(&:survey_id) unless @answer_sheets[person].empty?
        
        #get all of the questions for each person and answer sheet... three dimensional because I need to know
        # the person the answer is for and the answer_sheet
        @answer_sheets[person].each do |as|
          @questions[person][as] = as.survey.questions
          #push all of the questions onto all_questions so we can print out all of the uniq questions
          @all_questions << @questions[person][as]
        end
      end
    end
    
    #flatten and uniquize all of the questions & survey_ids for display
    @all_questions = @all_questions.flatten(2).uniq
    @all_survey_ids = @all_survey_ids.flatten(3).uniq

    #get the keywords belonging to the questions sheets that the request people filled out
    @keywords = SmsKeyword.where(survey_id: @all_survey_ids)
    @keys = @keywords.collect {|k| {name: k.keyword, keyword_id: k.id, questions: k.survey.questions.collect {|q| q.id}}}

    json_output = {keywords: @keys, questions: @all_questions.collect {|q| q.attributes.slice('id', 'kind', 'label', 'style', 'required')}, people: @people.collect {|person| {person: person.to_hash(@organization), form: (@answer_sheets[person].collect {|as| @questions[person][as].collect {|q| {q: q.id, a: q.display_response(as)}}}).flatten(2).uniq}}}
    final_output = Rails.env.production? ? json_output.to_json : JSON::pretty_generate(json_output)
    render json: final_output
  end
  
  def show_2
    @answer_sheets = {}
    @surveys = {}
    @questions = {}
    @people = get_people
    @all_questions = []
    @all_survey_ids = []
    unless @people.empty?
      @people.each do |person|
        @questions[person] = {}
        #get all of the possible question sheets in the request organization
        @surveys = @organization.surveys
        #find all of the answer sheets from this person that belong to this organization
        @answer_sheets[person] = person.answer_sheets.where(survey_id: @surveys)
        @all_survey_ids << @answer_sheets[person].collect(&:survey_id) unless @answer_sheets[person].empty?
        
        #get all of the questions for each person and answer sheet... three dimensional because I need to know
        # the person the answer is for and the answer_sheet
        @answer_sheets[person].each do |as|
          @questions[person][as] = as.survey.questions.all
          @all_questions << @questions[person][as]
        end
      end
    end
    
    @all_questions.flatten!
    
    @surveys = Survey.where(id: @all_survey_ids).collect {|s| {name: s.title, id: s.id, questions: s.questions.collect {|q| q.id}}}
    
    json_output = @api_json_header
    
    json_output.merge!({surveys: @surveys, questions: @all_questions.collect {|q| q.attributes.slice('id', 'kind', 'label', 'style', 'required')}, people: @people.collect {|person| {person: person.to_hash(@organization), form: (@answer_sheets[person].collect {|as| @questions[person][as].collect {|q| {q: q.id, a: q.display_response(as)}}}).flatten(2).uniq}}})
    json_output[:contacts] = @people.collect {|person| {person: person.to_hash(@organization), form: (@answer_sheets[person].collect {|as| @questions[person][as].collect {|q| {q: q.id, a: q.display_response(as)}}}).flatten(2).uniq}}
    
    final_output = Rails.env.production? ? json_output.to_json : JSON::pretty_generate(json_output)
    render json: final_output
  end

  def create_2
    create_contact
  end
end