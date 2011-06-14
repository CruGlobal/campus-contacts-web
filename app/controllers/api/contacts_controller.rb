class Api::ContactsController < ApiController
  require 'api_helper'
  include ApiHelper  
  skip_before_filter :authenticate_user!
  oauth_required
  
  def index_1
    valid_fields = valid_request_with_rescue(request)
    return render :json => valid_fields if valid_fields.is_a? Hash
    return render :json => {:error => "You do not have the appropriate organization memberships to view this data."} unless organization_allowed?
    dh = []

    if params[:keyword]
      @keywords = SmsKeyword.find_all_by_keyword(params[:keyword])
    elsif params[:org] 
      @keywords = SmsKeyword.find_all_by_organization_id(params[:org])
    elsif params[:keyword_id]
      @keywords = SmsKeyword.find_all_by_id(params[:id])
    else @keywords = SmsKeyword.find_all_by_organization_id(get_me.primary_organization.id)
    end

    unless @keywords.empty?
      
      # @questions = @keywords.collect(&:questions).flatten.uniq
      @question_sheets = @keywords.collect(&:question_sheet)
      # @keys = @keywords.collect {|k| {name: k.keyword, keyword_id: k.id, questions: k.questions.collect {|q| q.id}}}
      @people = Person.who_answered(@question_sheets).order('lastName, firstName')
      if params[:assigned_to]
        if params[:assigned_to] == 'none'
          @people = unassigned_people
        else
          @assigned_to = Person.find(params[:assigned_to])
          @people = @people.joins(:assigned_tos).where('contact_assignments.question_sheet_id' => @question_sheets.collect(&:id), 'contact_assignments.assigned_to_id' => @assigned_to.id)
        end
      end
      # @answer_sheets = {}
      # @people.each do |person|
      #   @answer_sheets[person] = person.answer_sheets.detect {|as| @question_sheets.collect(&:id).include?(as.question_sheet_id)}
      # end
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