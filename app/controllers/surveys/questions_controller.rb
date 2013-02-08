class Surveys::QuestionsController < ApplicationController
  before_filter :find_survey_and_authorize, except: [:hide, :unhide]
  before_filter :find_question, only: [:show, :edit, :update, :destroy]
  before_filter :get_predefined
  before_filter :get_leaders

  # GET /questions
  # GET /questions.xml
  def index
    session[:wizard] = false
    @questions = @survey.questions
    @predefined_questions = @predefined.questions.uniq - @questions
    @other_questions = current_organization.all_questions.uniq - @predefined.questions.uniq - @survey.questions
    respond_to do |wants|
      wants.html # index.html.erb
      wants.xml  { render xml: @questions }
    end
  end

  # GET /questions/1
  # GET /questions/1.xml
  def show
    respond_to do |wants|
      wants.html # show.html.erb
      wants.xml  { render xml: @question }
    end
  end

  # GET /questions/new
  # GET /questions/new.xml
  def new
    @survey = Survey.find(params[:survey_id])
  end

  # GET /questions/1/edit
  def edit
  end

  def reorder
    @survey.survey_elements.each do |pe|
      if params['questions'].index(pe.element_id.to_s)
        pe.position = params['questions'].index(pe.element_id.to_s) + 1
        pe.save!
      end
    end
    render nothing: true
  end

  # POST /questions
  # POST /questions.xml
  def create
    if (params[:question_id])
      @question = Element.find(params[:question_id])
    else
      # return unless validate_then_create_chosen_leaders
      type, style = params[:question_type].split(':')
      @question = type.constantize.create!(params[:question].merge(style: style))
    end

    # If this was an archived question, unarchive it. otherwise, add it
    if @survey.archived_questions.include?(@question)
      pe = SurveyElement.where(survey_id: @survey.id, element_id: @question.id).first
      pe.update_attribute(:archived, false)
    else
      begin
        @survey.elements << @question
      rescue ActiveRecord::RecordInvalid => e
         params[:error] = I18n.t('surveys.questions.create.duplicate_error')
         respond_to do |wants|
          wants.js
         end

         return
      end
    end

    params[:id] = @question.id
    return unless evaluate_option_autonotify # to avoid double render
    evaluate_option_autoassign

    respond_to do |wants|
      if !@question.new_record?
        wants.html do
          #flash[:notice] = t('questions.create.notice')
          #redirect_to(:back)
        end
        wants.xml  { render xml: @question, status: :created, location: @question }
        wants.js
      else
        wants.html { render action: "new" }
        wants.xml  { render xml: @question.errors, status: :unprocessable_entity }
        wants.js
      end
    end
  end

  # PUT /questions/1
  # PUT /questions/1.xml
  def update
    params[:question] ||= params[:choice_field] ||= params[:text_field]
    respond_to do |wants|
      if @question.update_attributes(params[:question])
        evaluate_option_autonotify
        evaluate_option_autoassign
        wants.js {}
        wants.xml  { head :ok }
      else
        wants.html { render action: "edit" }
        wants.xml  { render xml: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.xml
  def destroy
    # If a question is on more than one survey, or has been answered, remove it from this survey, but don't delete it for real.
    if @question.surveys.length > 1 || (@question.respond_to?(:sheet_answers) && @question.sheet_answers.count > 0)
      se = SurveyElement.where(survey_id: @survey.id, element_id: @question.id).first
      se.update_attribute(:archived, true) if se
    else
      @question.destroy
    end

    respond_to do |wants|
      wants.html { redirect_to(questions_url) }
      wants.xml  { head :ok }
      wants.js
    end
  end

  def hide
    @predefined_survey = Survey.find(APP_CONFIG['predefined_survey'])
    @predefined_questions = @predefined_survey.questions
    if @predefined_questions.collect(&:id).include?(params[:id].to_i)
      @question = @predefined_survey.elements.find(params[:id].to_i)
      @organization = current_organization
      @organization.survey_elements.each do |pe|
        pe.update_attribute(:hidden, true) if pe.element_id == @question.id
      end
      if current_organization.settings[:visible_predefined_questions].present?
        current_organization.settings[:visible_predefined_questions] = current_organization.settings[:visible_predefined_questions].reject {|x| x == @question.id}
        current_organization.save!
      end
    else
      @survey = Survey.find(params[:survey_id])
      @question = Element.find(params[:id])
      @organization = @survey.organization
      @organization.survey_elements.each do |pe|
        pe.update_attribute(:hidden, true) if pe.element_id == @question.id
      end
    end
  end

  def unhide
    @predefined_survey = Survey.find(APP_CONFIG['predefined_survey'])
    @predefined_questions = @predefined_survey.questions
    if @predefined_questions.collect(&:id).include?(params[:id].to_i)
      @question = @predefined_survey.elements.find(params[:id].to_i)
      @organization = current_organization
      @survey = @predefined_survey
      current_organization.settings[:visible_predefined_questions] = Array.new if current_organization.settings[:visible_predefined_questions].nil?
      current_organization.settings[:visible_predefined_questions] << @question.id
      current_organization.save!
    else
      @survey = Survey.find(params[:survey_id])
      @organization = @survey.organization
      @organization.survey_elements.each do |pe|
        pe.update_attribute(:hidden, false) if pe.element_id == params[:id].to_i
      end
    end
    redirect_to :back
  end

  def suggestion
    type = params[:type]
    keyword = params[:keyword].strip
    survey = @survey
    response = Array.new
    if type == 'Leader'
      results = @survey.organization.leaders.where("last_name LIKE ? OR first_name LIKE ?", "%#{keyword}%", "%#{keyword}%")
      response = results.uniq.collect{|leader| {"label"=>"#{leader.name} (#{leader.email})", "id"=>leader.id}}
    elsif type == 'Ministry'
      results = current_person.all_organization_and_children.where("name LIKE ?", "%#{keyword}%")
      response = results.uniq.collect{|ministry| {"label"=>"#{ministry.name}", "id"=>ministry.id}}
    elsif type == 'Group'
      if current_organization.present?
        results = current_organization.groups.where("name LIKE ?", "%#{keyword}%")
        response = results.uniq.collect{|group| {"label"=>"#{group.name} (#{group.location})", "id"=>group.id}}
      end
    elsif type == 'Label'
      results = current_organization.roles.where("name LIKE ?", "%#{keyword}%")
      response = results.uniq.collect{|label| {"label"=>"#{label.name}", "id"=>label.id}}
    end
    render json: response
  end

  private
    def find_question
      @question = @survey.elements.find(params[:id])
    end

    def find_survey_and_authorize
      @survey = Survey.find(params[:survey_id])
      authorize! :manage, @survey
    end

    def get_predefined
      @predefined = Survey.find(APP_CONFIG['predefined_survey'])
    end

    def get_leaders
      @leaders = current_organization.leaders
    end

    def evaluate_option_autoassign
      parameters = Hash.new
      parameters['type'] = params[:assign_contact_to]
      parameters['id'] = params[:autoassign_selected_id]
      parameters['name'] = params[:autoassign_keyword]

      rule = Rule.find_by_rule_code("AUTOASSIGN")
      triggers_array = Array.new
      triggers = params[:assignment_trigger_words].present? ? params[:assignment_trigger_words].split(',') : []
      triggers.each do |t|
        triggers_array << t.strip if t.strip.present?
      end
      triggers = triggers_array.join(", ")

      if parameters['id'].present? && parameters['name'].present?
        survey_element_id = SurveyElement.find_by_survey_id_and_element_id(params[:survey_id], params[:id]).id
        if question_rule = QuestionRule.find_by_survey_element_id_and_rule_id(survey_element_id, rule.id)
          question_rule.update_attribute('trigger_keywords',triggers)
          question_rule.update_attribute('extra_parameters',parameters)
        else
          question_rule = QuestionRule.create(survey_element_id: survey_element_id, rule_id: rule.id,
            trigger_keywords: triggers, extra_parameters: parameters)
        end
      end
    end

    def evaluate_option_autonotify
      leaders = params[:leaders] || []

      parameters = Hash.new
      parameters['leaders'] = Array.new
      invalid_emails = Array.new

      if leaders.present?
        survey_element_id = SurveyElement.find_by_survey_id_and_element_id(params[:survey_id], params[:id]).id
        leaders.each do |leader|
          Person.find(leader).has_a_valid_email? ? parameters['leaders'] << leader.to_i : invalid_emails << leader.to_i
        end

        if invalid_emails.present?
          respond_to do |wants|
            wants.js { render 'update_question_error', :locals => {:leader_names => Person.where(id: invalid_emails).collect{|p| p.name}.join(', ') } }
          end
          return false
        else
          rule = Rule.find_by_rule_code("AUTONOTIFY")
          triggers_array = Array.new
          triggers = params[:trigger_words].split(',')
          triggers.each do |t|
            triggers_array << t.strip if t.strip.present?
          end
          triggers = triggers_array.join(", ")
          if question_rule = QuestionRule.find_by_survey_element_id_and_rule_id(survey_element_id, rule.id)
            question_rule.update_attribute('trigger_keywords',triggers)
            question_rule.update_attribute('extra_parameters',parameters)
          else
            question_rule = QuestionRule.create(survey_element_id: survey_element_id, rule_id: rule.id,
              trigger_keywords: triggers, extra_parameters: parameters)
          end
        end
      end
      true
    end

    #def validate_then_create_chosen_leaders
    #  new_leaders = params[:leaders] || []
    #  old_leaders = params[:id] ? Question.find(params[:id]).question_leaders.collect{ |ql| ql.person_id.to_s} : []

    #  to_add = new_leaders - old_leaders
    #  to_remove = old_leaders - new_leaders

      #destroy question leaders
    #  Question.find(params[:id]).question_leaders.each do |ql|
    #    ql.destroy if to_remove.include? ql.person_id
    #  end if params[:id]

      #create question leaders
    #  leaders_with_invalid_emails = Array.new
    #  to_add.each do |ta|
    #    leaders_with_invalid_emails << ta unless Person.find(ta).has_a_valid_email?
    #  end

    #  unless leaders_with_invalid_emails.blank?
    #    respond_to do |wants|
    #      wants.js { render 'update_question_error', :locals => {:leader_names => Person.where(id: leaders_with_invalid_emails).collect{|p| p.name}.join(', ') } }
    #    end
    #    return false
    #  else
    #    to_add.each do |ta|
    #      QuestionLeader.create!(:person_id => ta, :element_id => @question.id)
    #    end
    #  end
    #  true
    #end
end
