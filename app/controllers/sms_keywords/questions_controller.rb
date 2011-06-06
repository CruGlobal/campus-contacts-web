class SmsKeywords::QuestionsController < ApplicationController
  before_filter :find_keyword
  before_filter :find_question, :only => [:show, :edit, :update, :destroy]

  # GET /questions
  # GET /questions.xml
  def index
    @questions = @keyword.question_sheet.elements
    @predefined = QuestionSheet.find(APP_CONFIG['predefined_question_sheet'])
    respond_to do |wants|
      wants.html # index.html.erb
      wants.xml  { render :xml => @questions }
    end
  end

  # GET /questions/1
  # GET /questions/1.xml
  def show
    respond_to do |wants|
      wants.html # show.html.erb
      wants.xml  { render :xml => @question }
    end
  end

  # GET /questions/new
  # GET /questions/new.xml
  def new
    @question = @keyword.question_sheet.elements.new

    respond_to do |wants|
      wants.html # new.html.erb
      wants.xml  { render :xml => @question }
    end
  end

  # GET /questions/1/edit
  def edit
  end
  
  def reorder 
    @keyword.question_page.page_elements.each do |pe|
      if params['questions'].index(pe.element_id.to_s)
        pe.position = params['questions'].index(pe.element_id.to_s) + 1 
        pe.save!
      end
    end
    render :nothing => true
  end

  # POST /questions
  # POST /questions.xml
  def create
    if (params[:question_id])
      @question = Element.find(params[:question_id])
    else
      type, style = params[:question_type].split(':')
      @question = type.constantize.create!(params[:question].merge(:style => style))
    end
    @keyword.question_page.elements << @question

    respond_to do |wants|
      if !@question.new_record?
        wants.html do
          flash[:notice] = t('ma.questions.create.notice')
          redirect_to(:back) 
        end
        wants.xml  { render :xml => @question, :status => :created, :location => @question }
        wants.js
      else
        wants.html { render :action => "new" }
        wants.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
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
        wants.html { render :action => "edit" }
        wants.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.xml
  def destroy
    # If a question is on more than one page, or has been answered, remove it from this question sheet, but don't delete it for real.
    if @question.pages.length > 1 || (@question.respond_to?(:sheet_answers) && @question.sheet_answers.count > 0)
      PageElement.where(:page_id => @keyword.question_page.id, :element_id => @question.id).first.try(:destroy)
    else
      @question.destroy
    end

    respond_to do |wants|
      wants.html { redirect_to(questions_url) }
      wants.xml  { head :ok }
      wants.js
    end
  end

  private
    def find_question
      @question = @keyword.question_page.elements.find(params[:id])
    end
    
    def find_keyword
      @keyword = SmsKeyword.includes(:question_sheets).find(params[:sms_keyword_id])
    end

end
