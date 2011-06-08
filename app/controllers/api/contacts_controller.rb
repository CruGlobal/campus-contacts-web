class Api::ContactsController < ApiController
  require 'api_helper'
  include ApiHelper  
  skip_before_filter :authenticate_user!
  oauth_required
  
  def index_1
    valid_fields = valid_request?(request)
    if valid_fields.is_a? Hash
       dh = valid_fields
    else 
      if params[:keyword] 
        @keywords = SmsKeyword.find_all_by_id(params[:keyword])  
        @questions = @keywords.collect(&:questions).flatten.uniq
        @question_sheets = @keywords.collect(&:question_sheet)
      elsif params[:org] 
        @organization = Organization.find(params[:org])
        @questions = @organization.questions.where("#{PageElement.table_name}.hidden" => false).flatten.uniq
        @question_sheets = @organization.question_sheets
      end
      
        @people = Person.who_answered(@question_sheets).order('lastName, firstName')

        if params[:assigned_to]
          if params[:assigned_to] == 'none'
            @people = unassigned_people
          else
            @assigned_to = Person.find(params[:assigned_to])
            @people = @people.joins(:assigned_tos).where('contact_assignments.question_sheet_id' => @question_sheet.id, 'contact_assignments.assigned_to_id' => @assigned_to.id)
          end
        end
        
        @answer_sheets = {}
        @people.each do |person|
          @answer_sheets[person] = person.answer_sheets.detect {|as| @question_sheets.collect(&:id).include?(as.question_sheet_id)}
        end
       dh = {questions: @questions.collect {|q| q.attributes.slice('id', 'kind', 'label', 'style', 'required', 'content')}, people: @people.collect {|person| {person: person.to_hash, form: @questions.collect {|q| {q: q.id, a: q.display_response(@answer_sheets[person])}}}}}
    end
    render :json => JSON::pretty_generate(dh)
  end
  
  def show_1
    valid_fields = valid_request?(request)
    if valid_fields.is_a? Hash
       dh = valid_fields
    else
      @answer_sheets = {}
      @question_sheets = []
      @people = get_people
      @people.each do |person|
        @answer_sheets[person] = person.answer_sheets.first
        @question_sheets.push person.answer_sheets.collect{|x| x.question_sheet}
      end
      @question_sheets.flatten!.uniq!
      #raise @question_sheets.first.questions.inspect
      @questions = (@question_sheets.collect { |q| q.questions }).flatten.uniq
      dh = {questions: @questions.collect {|q| q.attributes.slice('id', 'kind', 'label', 'style', 'required', 'content')}, people: @people.collect {|person| {person: person.to_hash, form: @questions.collect {|q| {q: q.id, a: q.display_response(@answer_sheets[person])}}}}}
    end
    render :json => JSON::pretty_generate(dh)
  end
end