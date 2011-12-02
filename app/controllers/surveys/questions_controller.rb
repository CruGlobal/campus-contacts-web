class Surveys::QuestionsController < ApplicationController
  before_filter :find_survey_and_authorize
  before_filter :find_question, only: [:show, :edit, :update, :destroy]
  before_filter :get_predefined

  # GET /questions
  # GET /questions.xml
  def index
    session[:wizard] = false
    @questions = @survey.questions
    @archived_questions = @survey.archived_questions
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
    @question = @survey.question_sheet.elements.new

    respond_to do |wants|
      wants.html # new.html.erb
      wants.xml  { render xml: @question }
    end
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
      type, style = params[:question_type].split(':')
      @question = type.constantize.create!(params[:question].merge(style: style))
    end
    
    # If this was an archived question, unarchive it. otherwise, add it
    if @survey.archived_questions.include?(@question)
      pe = PageElement.where(survey_id: @survey.id, element_id: @question.id).first
      pe.update_attribute(:archived, false)
    else
      @survey.elements << @question
    end

    respond_to do |wants|
      if !@question.new_record?
        wants.html do
          flash[:notice] = t('questions.create.notice')
          redirect_to(:back) 
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
      se.update_attribute(:archived, true) if pe
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
    @question = Element.find(params[:id])
    @organization = @survey.organization
    @organization.survey_elements.each do |pe|
      pe.update_attribute(:hidden, true) if pe.element_id == @question.id
    end
  end

  def unhide
    @organization = @survey.organization
    @organization.survey_elements.each do |pe|
      pe.update_attribute(:hidden, false) if pe.element_id == params[:id].to_i
    end
    redirect_to :back
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

end
