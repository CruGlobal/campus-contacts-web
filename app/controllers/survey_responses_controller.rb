class SurveyResponsesController < ApplicationController
  prepend_before_filter :set_keyword_cookie, only: :new
  before_filter :get_person
  before_filter :get_keyword
  before_filter :prepare_for_mobile
  skip_before_filter :authenticate_user!, except: :update
  skip_before_filter :check_url
  
  def new
    unless mhub? || Rails.env.test?
      redirect_to new_survey_response_url(params.merge(host: APP_CONFIG['public_host'], port: APP_CONFIG['public_port']))
      return false
    end
    
    # If they haven't skipped facebook already, send them to the login page
    unless params[:nologin] == 'true'
      return unless authenticate_user! 
    end
    
    # If they texted in, save their phone number
    if @sms
      if @person.new_record?
        @person.phone_numbers.new(:number => @sms.phone_number)
      else
        @person.phone_numbers.create!(number: @sms.phone_number, location: 'mobile') unless @person.phone_numbers.detect {|p| p.number_with_country_code == @sms.phone_number}
        @sms.update_attribute(:person_id, @person.id) unless @sms.person_id
      end
    end
    
    if @keyword
      @answer_sheet = get_answer_sheet(@keyword, @person)
      respond_to do |wants|
        wants.html { render :layout => 'mhub'}
        wants.mobile
      end
    else
      render_404 and return
    end
  end
  
  def show
    @person = Person.find(params[:id])
    authorize! :followup, @person
  end
  
  def edit
    @person = Person.find(params[:id])
    authorize! :followup, @person
  end
  
  def update
    # A survey responder should always be updating their own record
    redirect_to :back and return false unless @person.id == params[:id].to_i
    
    save_survey

    if @person.valid? && @answer_sheet.person.valid?
      create_contact_at_org(@person, @keyword.organization)
      respond_to do |wants|
        wants.html { render :thanks, layout: 'mhub'}
        wants.mobile { render :thanks }
      end
    else
      @answer_sheet = get_answer_sheet(@keyword, @person)
      respond_to do |wants|
        wants.html { render :new, layout: 'mhub'}
        wants.mobile { render :new }
      end
    end
  end
  
  def create
    Person.transaction do
      @person = Person.create(params[:person])
      if @person.valid?
        save_survey
      
        if @person.valid? && @answer_sheet.person.valid?
          create_contact_at_org(@person, @keyword.organization)
          FollowupComment.create_from_survey(@keyword.organization, @person, @keyword.questions, @answer_sheet)
          respond_to do |wants|
            wants.html { render :thanks, layout: 'mhub'}
            wants.mobile { render :thanks }
          end
        else
          @answer_sheet = get_answer_sheet(@keyword, @person)
          respond_to do |wants|
            wants.html { render :new, layout: 'mhub'}
            wants.mobile { render :new }
          end
        end
      else
        @answer_sheet = get_answer_sheet(@keyword, @person)
        respond_to do |wants|
          wants.html { render :new, layout: 'mhub'}
          wants.mobile { render :new }
        end
      end
    end
  end
  
  protected
  
    def save_survey
      @person.update_attributes(params[:person]) if params[:person]
      @answer_sheet = get_answer_sheet(@keyword, @person)
      question_set = QuestionSet.new(@keyword.questions, @answer_sheet)
      question_set.post(params[:answers], @answer_sheet)
      question_set.save
    end
    
    def get_keyword
      if params[:keyword]
        @keyword ||= SmsKeyword.where(keyword: params[:keyword]).first 
      elsif params[:received_sms_id]
        sms_id = Base62.decode(params[:received_sms_id])
        @sms = SmsSession.find_by_id(sms_id) || ReceivedSms.find_by_id(sms_id)
        if @sms
          @keyword ||= @sms.sms_keyword || SmsKeyword.where(keyword: @sms.message.strip).first
        end
      end
      if params[:keyword] || params[:received_sms_id]
        unless @keyword
          render_404 
          return false
        end
        @questions = @keyword.questions
      end
    end
    
    def set_keyword_cookie
      get_keyword
      if @keyword
        cookies[:keyword] = @keyword.keyword 
      else
        return false
      end
    end
    
    def get_person
      @person = user_signed_in? ? current_user.person : Person.new
    end
end
