class SurveyResponsesController < ApplicationController
  before_filter :get_person
  before_filter :get_survey, except: [:show, :edit]
  before_filter :set_keyword_cookie, only: :new
  before_filter :prepare_for_mobile
  skip_before_filter :authenticate_user!, except: [:update, :live]
  skip_before_filter :check_url

  def new
    unless mhub? || Rails.env.test?
      redirect_to new_survey_response_url(params.merge(host: APP_CONFIG['public_host'], port: APP_CONFIG['public_port']))
      return false
    end

    # If they haven't skipped facebook already, send them to the login page
    # Also skip login if we're in survey mode
    unless params[:nologin] == 'true' || (@sms && @sms.sms_keyword.survey.login_option == Survey::NO_LOGIN)
      return unless authenticate_user!
    end
    # If they texted in, save their phone number
    if @sms
      if @person.new_record?
        @person.phone_number = @sms.phone_number
        @person.first_name = @sms.person.first_name
        @person.last_name = @sms.person.last_name
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

    ['birth_date','graduation_date'].each do |attr_name|
      if date_element = @survey.questions.where(attribute_name: attr_name)
        if date_element.present? && params[:answers]["#{date_element.first.id}"].present?
          @person.birth_date = params[:answers]["#{date_element.first.id}"] if attr_name == 'birth_date'
          @person.graduation_date = params[:answers]["#{date_element.first.id}"] if attr_name == 'graduation_date'
        end
      end
    end

    if @person.valid? && @answer_sheet.person.valid?
      unless @answer_sheet.survey.has_assign_rule_applied(@answer_sheet, 'ministry')
        create_contact_at_org(@person, @survey.organization)
      end
      destroy_answer_sheet_when_answers_are_all_blank
      if @survey.redirect_url.to_s =~ /https?:\/\//
        redirect_to @survey.redirect_url and return false
      else
        @current_person = @eperson
        respond_to do |wants|
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
  end

  def create
    @title = @survey.terminology
    Person.transaction do
      @person = current_person # first try for a logged in person
      if params[:person]
        if params[:person][:email].present?
          # See if we can match someone by email
          existing_person = EmailAddress.where(email: params[:person][:email]).first.try(:person)
        end

        params[:person][:phone_number] = @sms.phone_number if params[:person][:phone_number].blank? && @sms.present?
        if params[:person][:phone_number].present?
          # See if we can match someone by name and phone number
          existing_person = Person.find_existing_person_by_name_and_phone(number: params[:person][:phone_number],
                                                                          first_name: params[:person][:first_name],
                                                                          last_name: params[:person][:last_name])
        end
      else
        params[:person] = Hash.new
      end

      ['birth_date','graduation_date'].each do |attr_name|
        if date_element = @survey.questions.where(attribute_name: attr_name)
          params[:person][:"#{attr_name}"] = params[:answers]["#{date_element.first.id}"] if date_element.present? && params[:answers]["#{date_element.first.id}"].present?
        end
      end

      if existing_person
        if @person
          @person = existing_person.smart_merge(@person) unless @person == existing_person
        else
          @person = existing_person
        end
      end

      if @person
        @person.update_attributes(params[:person])
      else
        @person = Person.create(params[:person])
      end

      @current_person = @person
      if @person.valid?
        NewPerson.create(person_id: @person.id, organization_id: @survey.organization.id)
        save_survey
        session[:person_id] = @person.id
        session[:survey_id] = @survey.id
        if @person.valid? && @answer_sheet.person.valid?
          unless @answer_sheet.survey.has_assign_rule_applied(@answer_sheet, 'ministry')
            create_contact_at_org(@person, @survey.organization)
            FollowupComment.create_from_survey(@survey.organization, @person, @survey.questions, @answer_sheet)
          end
          destroy_answer_sheet_when_answers_are_all_blank
          respond_to do |wants|
            if @survey.login_option == 2
              wants.html { render :facebook, layout: 'mhub' }
              wants.mobile { render :facebook, layout: 'mhub' }
            else
              # If we saved successfully, destroy the session
              session[:person_id] = nil
              session[:survey_id] = nil
              if @survey.redirect_url.to_s =~ /https?:\/\//
                redirect_to @survey.redirect_url and return false
              else
                wants.html { render :thanks, layout: 'mhub'}
                wants.mobile { render :thanks }
              end
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

  def live
    current_organization.generate_api_secret unless current_organization.api_client

    render layout: false
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

  def destroy_answer_sheet_when_answers_are_all_blank
    @answer_sheet.destroy if !params[:answers].present? || (params[:answers] && params[:answers].values.reject{|x| x.nil? || x.empty?}.blank?) # if a person has blank answers in a survey, destroy!
  end

  def get_person
    @person = current_person || Person.new
  end
end
