class Api::ContactsController < ApiController
  oauth_required scope: "contacts"
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?, :get_organization
  
  def search_1
    @keywords = get_keywords
    json_output = []
    unless (@keywords.empty? || !params[:term].present?)
      @question_sheets = @keywords.collect(&:question_sheet)
      @people = Person.who_answered(@question_sheets).where('CONCAT(`ministry_person`.`firstName`," ", `ministry_person`.`lastName`) LIKE ? OR `ministry_person`.`lastName` LIKE ? OR CONCAT(`ministry_person`.`preferredName`," ", `ministry_person`.`lastName`) LIKE ?',"%#{params[:term]}%","%#{params[:term]}%","%#{params[:term]}%")
      @people = paginate_filter_sort_people(@people,@organization)      
      json_output = @people.collect {|person|  { person: person.to_hash_basic(@organization)}}
    end
    final_output = Rails.env.production? ? json_output.to_json : JSON::pretty_generate(json_output)
    render json: final_output
  end
  
  def index_1
    @keywords = get_keywords
    json_output = []
    # unless @keywords.empty?
      @question_sheets = @keywords.collect(&:question_sheet)
      # @people = Person.who_answered(@question_sheets)
      @people = @organization.contacts#.order('lastName, firstName')
      @people = paginate_filter_sort_people(@people, @organization)
      json_output = @people.collect {|person| {person: person.to_hash_basic(@organization)}}
    # end
    final_output = Rails.env.production? ? json_output.to_json : JSON::pretty_generate(json_output)
    render json: final_output
  end
  
  def show_1
    @filled_out_question_sheets = {}
    @answer_sheets = {}
    @question_sheets = {}
    @questions = {}
    @filled_out_org_question_sheets = {}
    @all_questions = []
    @all_question_sheet_ids = []
    json_output = {}
    @people = get_people
    unless @people.empty?
      @people.each do |person|
        @questions[person] = {}
        #get all of the possible question sheets in the request organization
        @question_sheets = @organization.question_sheets
        #find all of the answer sheets from this person that belong to this organization
        @answer_sheets[person] = person.answer_sheets.where(question_sheet_id: @question_sheets)
        #push all of the question sheet ids onto an arroy so we can build the keywords answered by all people in the request
        @all_question_sheet_ids << @answer_sheets[person].collect(&:question_sheet_id) unless @answer_sheets[person].empty?
        
        #get all of the questions for each person and answer sheet... three dimensional because I need to know
        # the person the answer is for and the answer_sheet
        @answer_sheets[person].each do |as|
          @questions[person][as] = as.question_sheet.questions
          #push all of the questions onto all_questions so we can print out all of the uniq questions
          @all_questions << @questions[person][as]
        end
      end
    end
    
    #flatten and uniquize all of the questions & question_sheet_ids for display
    @all_questions = @all_questions.flatten(2).uniq
    @all_question_sheet_ids = @all_question_sheet_ids.flatten(3).uniq

    #get the keywords belonging to the questions sheets that the request people filled out
    @keywords = QuestionSheet.where(id: @all_question_sheet_ids).collect { |k| k.questionnable}.flatten.uniq
    @keys = @keywords.collect {|k| {name: k.keyword, keyword_id: k.id, questions: k.questions.collect {|q| q.id}}}

    json_output = {keywords: @keys, questions: @all_questions.collect {|q| q.attributes.slice('id', 'kind', 'label', 'style', 'required')}, people: @people.collect {|person| {person: person.to_hash(@organization), form: (@answer_sheets[person].collect {|as| @questions[person][as].collect {|q| {q: q.id, a: q.display_response(as)}}}).flatten(2).uniq}}}
    final_output = Rails.env.production? ? json_output.to_json : JSON::pretty_generate(json_output)
    render json: final_output
  end
end