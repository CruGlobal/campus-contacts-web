class SurveyResponsesController < ApplicationController
  before_filter :get_person
  before_filter :get_survey, except: [:show, :edit]
  before_filter :set_keyword_cookie, only: :new
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

    if @survey
      @title = @survey.terminology 
      @answer_sheet = get_answer_sheet(@survey, @person)
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
    @title = @survey.terminology if @survey
    redirect_to :back and return false unless @person.id == params[:id].to_i

    save_survey

    if @person.valid? && @answer_sheet.person.valid?
      create_contact_at_org(@person, @survey.organization)
      respond_to do |wants|
        wants.html { render :thanks, layout: 'mhub'}
        wants.mobile { render :thanks }
      end
    else
      @answer_sheet = get_answer_sheet(@survey, @person)
      respond_to do |wants|
        wants.html { render :new, layout: 'mhub'}
        wants.mobile { render :new }
      end
    end
  end

  def create
    @title = @survey.terminology
    Person.transaction do
      @person = current_person # first try for a logged in person
      if params[:person] && params[:person][:email].present?
        @person_from_email = EmailAddress.find_by_email(params[:person][:email]).try(:person) || Address.find_by_email(params[:person][:email]).try(:person)
        if @person
          if @person != @person_from_email
            @person = @person_from_email.smart_merge(@person)
          end
        else
          @person = @person_from_email
        end
      end

      if @person
        @person.update_attributes(params[:person])
      else
        @person = Person.create(params[:person])
      end
      if @person.valid?
        NewPerson.create(person_id: @person.id, organization_id: @survey.organization.id)
        save_survey
        session[:person_id] = @person.id
        session[:survey_id] = @survey.id
        if @person.valid? && @answer_sheet.person.valid?
          create_contact_at_org(@person, @survey.organization)
          FollowupComment.create_from_survey(@survey.organization, @person, @survey.questions, @answer_sheet)
          respond_to do |wants|
            if @survey.login_option == 2
              wants.html { render :facebook, layout: 'mhub' }
              wants.mobile { render :facebook, layout: 'mhub' }
            else
              wants.html { render :thanks, layout: 'mhub'}
              wants.mobile { render :thanks }
            end
          end
        else
          @answer_sheet = get_answer_sheet(@survey, @person)
          respond_to do |wants|
            wants.html { render :new, layout: 'mhub'}
            wants.mobile { render :new }
          end
        end
      else
        @answer_sheet = get_answer_sheet(@survey, @person)
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
    @answer_sheet = get_answer_sheet(@survey, @person)
    question_set = QuestionSet.new(@survey.questions, @answer_sheet)
    question_set.post(params[:answers], @answer_sheet)
    question_set.save
    @answer_sheet.person.save
    @answer_sheet.update_attribute(:completed_at, Time.now)
  end

  def get_person
    @person = current_person || Person.new
  end
end
