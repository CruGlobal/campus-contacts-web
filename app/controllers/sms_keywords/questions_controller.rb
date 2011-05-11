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

  # POST /questions
  # POST /questions.xml
  def create
    if (params[:question_id])
      @question = Element.find(params[:question_id])
      @keyword.question_sheet.elements << @question
    else
      @question = @keyword.question_sheet.elements.new(params[:question])
    end

    respond_to do |wants|
      if @question.save
        flash[:notice] = 'Question was successfully created.'
        wants.html { redirect_to(@question) }
        wants.xml  { render :xml => @question, :status => :created, :location => @question }
      else
        wants.html { render :action => "new" }
        wants.xml  { render :xml => @question.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /questions/1
  # PUT /questions/1.xml
  def update
    respond_to do |wants|
      if @question.update_attributes(params[:question])
        flash[:notice] = '@keyword.question_sheet.elements.was successfully updated.'
        wants.html { redirect_to(@question) }
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
    @question.destroy

    respond_to do |wants|
      wants.html { redirect_to(questions_url) }
      wants.xml  { head :ok }
    end
  end

  private
    def find_question
      @question = @keyword.question_sheet.elements.find(params[:id])
    end
    
    def find_keyword
      @keyword = SmsKeyword.find(params[:sms_keyword_id])
    end

end
