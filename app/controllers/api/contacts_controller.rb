class Api::ContactsController < ApiController
  require 'api_helper'
  include ApiHelper  
  skip_before_filter :authenticate_user!
  oauth_required
  
  def search_1
    valid_fields = valid_request_with_rescue(request)
    return render :json => valid_fields if valid_fields.is_a? Hash
    return render :json => {:error => "You do not have the appropriate organization memberships to view this data."} unless organization_allowed?
    dh = []
    @keywords = get_keywords
    
    unless (@keywords.empty? && params[:term].nil?)
      @question_sheets = @keywords.collect(&:question_sheet)
      @people = Person.who_answered(@question_sheets).where('`ministry_person`.`firstName` LIKE ? OR `ministry_person`.`lastName` LIKE ? OR `ministry_person`.`preferredName` LIKE ?',"%#{params[:term]}%","%#{params[:term]}%","%#{params[:term]}%")
      @people = paginate_filter_sort_people(@people)      
      dh = @people.collect {|person|  { person: person.to_hash.slice('id','first_name','last_name','gender','picture','org_ids','status')}}
    end
    render :json => JSON::pretty_generate(dh)
  end
  
  def index_1
    valid_fields = valid_request_with_rescue(request)
    return render :json => valid_fields if valid_fields.is_a? Hash
    return render :json => {:error => "You do not have the appropriate organization memberships to view this data."} unless organization_allowed?
    dh = []
    @keywords = get_keywords
    unless @keywords.empty?
      @question_sheets = @keywords.collect(&:question_sheet)
      @people = Person.who_answered(@question_sheets)
      if params[:assigned_to]
        if params[:assigned_to] == 'none'
          @people = unassigned_people
        else
          @people = @people.joins(:assigned_tos).where('contact_assignments.question_sheet_id' => @question_sheets.collect(&:id), 'contact_assignments.assigned_to_id' => @assigned_to.id)
        end
      end
      dh = @people.collect {|person| {person: person.to_hash.slice('id','first_name','last_name','gender','picture','org_ids','status')}}
    end
    render :json => JSON::pretty_generate(dh)
  end
  
  def show_1
    valid_fields = valid_request_with_rescue(request)
    return render :json => valid_fields if valid_fields.is_a? Hash
    return render :json => {:error => "You do not have the appropriate organization memberships to view this data."} unless organization_allowed?
    dh = []
    
    @answer_sheets = {}
    @question_sheets = []
    @people = get_people
    @people.each do |person|
      @answer_sheets[person] = person.answer_sheets.first
      @question_sheets.push person.answer_sheets.collect{|x| x.question_sheet}
    end
    @question_sheets.flatten!.uniq!
    @questions = (@question_sheets.collect { |q| q.questions }).flatten.uniq
    @keywords = @question_sheets.collect { |k| k.questionnable}.flatten.uniq
    @keys = @keywords.collect {|k| {name: k.keyword, keyword_id: k.id, questions: k.questions.collect {|q| q.id}}}
    dh = {keywords: @keys, questions: @questions.collect {|q| q.attributes.slice('id', 'kind', 'label', 'style', 'required')}, people: @people.collect {|person| {person: person.to_hash, form: @questions.collect {|q| {q: q.id, a: q.display_response(@answer_sheets[person])}}}}}
    render :json => JSON::pretty_generate(dh)
  end
end