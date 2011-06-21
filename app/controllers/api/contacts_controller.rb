class Api::ContactsController < ApiController
  require 'api_helper'
  include ApiHelper  
  skip_before_filter :authenticate_user!
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?
  oauth_required :scope => "contacts"
  rescue_from Exception, :with => :render_json_error
  
  def search_1
    @keywords = get_keywords
    unless (@keywords.empty? && params[:term].nil?)
      org = get_organization
      @question_sheets = @keywords.collect(&:question_sheet)
      @people = Person.who_answered(@question_sheets).where('`ministry_person`.`firstName` LIKE ? OR `ministry_person`.`lastName` LIKE ? OR `ministry_person`.`preferredName` LIKE ?',"%#{params[:term]}%","%#{params[:term]}%","%#{params[:term]}%")
      @people = paginate_filter_sort_people(@people,org)      
      dh = @people.collect {|person|  { person: person.to_hash_basic(org)}}
    end
    render :json => JSON::pretty_generate(dh)
  end
  
  def index_1
    @keywords = get_keywords
    unless @keywords.empty?
      org = get_organization
      @question_sheets = @keywords.collect(&:question_sheet)
      @people = Person.who_answered(@question_sheets)
      if params[:assigned_to].present?
        if params[:assigned_to] == 'none'
          @people = unassigned_people
        else
          @people = @people.joins(:assigned_tos).where('contact_assignments.question_sheet_id' => @question_sheets.collect(&:id), 'contact_assignments.assigned_to_id' => @assigned_to.id)
        end
      end
      @people = paginate_filter_sort_people(@people, org)
      json_output = @people.collect {|person| {person: person.to_hash_basic(org)}}
    end
    final_output = Rails.env.production? ? json_output.to_json : JSON::pretty_generate(json_output)
    render :json => final_output
  end
  
  def show_1
    @answer_sheets = {}
    @people = get_people
    unless @people.empty?
      @organization = get_organization
      @question_sheets = @organization.question_sheets
      @questions = (@question_sheets.collect { |q| q.questions }).flatten.uniq
      @people.each do |person|
        @question_sheets.each do |qs|
          @answer_sheets[person] = person.answer_sheets.order('created_at DESC').detect {|as| qs.id == as.question_sheet_id}
        end
      end
      @keywords = @question_sheets.collect { |k| k.questionnable}.flatten.uniq
      @keys = @keywords.collect {|k| {name: k.keyword, keyword_id: k.id, questions: k.questions.collect {|q| q.id}}}
      json_output = {keywords: @keys, questions: @questions.collect {|q| q.attributes.slice('id', 'kind', 'label', 'style', 'required')}, people: @people.collect {|person| {person: person.to_hash(@organization), form: @questions.collect {|q| {q: q.id, a: q.display_response(@answer_sheets[person])}}}}}
    end
    final_output = Rails.env.production? ? json_output.to_json : JSON::pretty_generate(json_output)
    render :json => final_output
  end
end