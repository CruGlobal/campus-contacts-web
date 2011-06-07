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
      elsif params[:org] 
        @keywords = SmsKeyword.where("organization_id = ?", params[:org])
      else @keywords = nil
      end
      dh = []
      
      @keywords.each do |keyword|
        @question_sheet = keyword.question_sheet
        @organization = keyword.organization
        @people = Person.who_answered(@question_sheet).order('lastName, firstName')

        if params[:assigned_to]
          if params[:assigned_to] == 'none'
            @people = unassigned_people
          else
            @assigned_to = Person.find(params[:assigned_to])
            @people = @people.joins(:assigned_tos).where('contact_assignments.question_sheet_id' => @question_sheet.id, 'contact_assignments.assigned_to_id' => @assigned_to.id)
          end
        end
        @answer_sheet = []
        @people.each do |person|
          @answer_sheet.push (person.answer_sheets.detect {|as| as.question_sheet_id == @question_sheet.id })
        end

       #  @peeps = @people.collect {|z| z.to_hash}
       #   @answers = @answer_sheet.collect { |ax| @question_sheet.questions.collect {|x| x.display_response(ax)}}
       #   @questions = @question_sheet.questions.collect {|y| y.get_api_question_hash}
       # 
       #   0.upto(@peeps.length-1) do |p|
       #     hash = Hash.new
       #     hash = {"person" => @peeps[p]}
       #     qa = []
       #     0.upto(@questions.length-1) do |q|
       #       qa[q] = {"q" => @questions[q], "a" => @answers[p][q] }
       #     end
       #     hash[:form] = qa
       #     dh.push hash
       #   end
       end
       
       @answers = @answer_sheet.collect { |ax| @question_sheet.questions.collect {|x| x.display_response(ax)}}
       @questions = @question_sheet.questions.collect {|y| y.attributes.slice(:kind, :label, :style, :required, :content)}

       dh = @people.collect {|person| {person: person, form: @questions.collect {|q| {q: q, a: @answers[person][q]}}}}
    end
      #raise dh.to_json.inspect
    render :json => JSON::pretty_generate(dh)
  end
  
  def show_1
    
  end
end