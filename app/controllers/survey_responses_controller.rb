class SurveyResponsesController < ApplicationController
  before_filter :get_person
  before_filter :get_survey, except: [:show, :edit, :answer_other_surveys]
  before_filter :set_keyword_cookie, only: :new
  before_filter :prepare_for_mobile, except: [:show, :edit, :answer_other_surveys]
  before_filter :set_locale
  skip_before_filter :authenticate_user!, except: [:update, :live]
  skip_before_filter :check_url

  def new
    unless mhub? || Rails.env.test?
      protocol = Rails.env.development? ? 'http' : 'https'
      redirect_to new_survey_response_url(params.merge(protocol: protocol, host: APP_CONFIG['public_host'], port: APP_CONFIG['public_port']))
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
        if @sms.person
          @person.first_name = @sms.person.first_name
          @person.last_name = @sms.person.last_name
        end
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

    org = current_organization
    org ||= @person.organizations.first if @person.organizations

    if @person && org
      @completed_answer_sheets = @person.completed_answer_sheets(org)
    end
  end

  def edit
    @person = Person.find(params[:id])
    authorize! :followup, @person
  end

  def answer_other_surveys
    @person = Person.find(params[:id])
    authorize! :followup, @person
  end

  def update
    @title = @survey.terminology if @survey
    redirect_to :back and return false unless @person.id == params[:id].to_i

    # Update person record
    @person.update_attributes(params[:person])

    @answer_sheet = @person.answer_sheet_for_survey(@survey.id)

    ['birth_date','graduation_date'].each do |attr_name|
      if date_element = @survey.questions.where(attribute_name: attr_name)
        if date_element.present? && params[:answers]["#{date_element.first.id}"].present?
          @person.birth_date = params[:answers]["#{date_element.first.id}"] if attr_name == 'birth_date'
          @person.graduation_date = params[:answers]["#{date_element.first.id}"] if attr_name == 'graduation_date'
        end
      end
    end

    if @person.valid? && @answer_sheet.person.valid?
      # Save survey answers and manage question rules
      @answer_sheet.save_survey(params[:answers])

      destroy_answer_sheet_when_answers_are_all_blank

      if @survey.redirect_url.to_s =~ /https?:\/\//
        redirect_to @survey.redirect_url and return false
      else
        @current_person = @person
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

      # Ensure that there's a person hash
      params[:person] = Hash.new unless params[:person]

      ['birth_date','graduation_date', 'email'].each do |attr_name|
        if element = @survey.questions.find_by_attribute_name(attr_name)
          if element.predefined? && params[:answers]["#{element.id}"].present?
            params[:person][:"#{attr_name}"] = params[:answers]["#{element.id}"]
          end
        end
      end

      form_email_address = params[:person][:email]
      form_phone_number = params[:person][:phone_number]

      if form_email_address.present?
        # See if we can match someone by email
        existing_person = Person.find_existing_person_by_email(form_email_address)
      end

      unless existing_person.present?
        if form_phone_number.present? || (form_phone_number.blank? && @sms.present?)
          form_phone_number = @sms.phone_number if @sms.present?
          # See if we can match someone by name and phone number
          existing_person = Person.find_existing_person_by_name_and_phone(number: form_phone_number,
                                                                          first_name: params[:person][:first_name],
                                                                          last_name: params[:person][:last_name])
        end
      end

      if faculty_element = @survey.questions.where(attribute_name: 'faculty').first
        is_faculty = params[:answers]["#{faculty_element.id}"]
        if faculty_element.present? && is_faculty.present?
          params[:answers]["#{faculty_element.id}"] = is_faculty.downcase == "yes" ? true : false
        end
      end

      if existing_person
        if @person
          @person = existing_person.smart_merge(@person) unless @person == existing_person
        else
          @person = existing_person
        end
      else
        # Do not create a new person data when there's an existing to avoid duplicate data
        @person = Person.create(params[:person])
      end

      @current_person = @person
      if @person.valid?
        @org = @survey.organization
        NewPerson.create(person_id: @person.id, organization_id: @org.id)

        @answer_sheet = @person.answer_sheet_for_survey(@survey.id)

        session[:person_id] = @person.id
        session[:survey_id] = @survey.id
        if @person.valid? && @answer_sheet.person.valid?
          # Do not change the permission if there's an existing permission (add_contact method handles it)
          @org.add_contact(@person)

          # Update person record
          @person.update_attributes(params[:person])

          # Save survey answers and manage question rules
          @answer_sheet.save_survey(params[:answers])

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
    @answer_sheet = @person.answer_sheet_for_survey(@survey.id)
    @answer_sheet.save_survey(params[:answers])
  end

  def destroy_answer_sheet_when_answers_are_all_blank
    @answer_sheet.destroy if !params[:answers].present? || (params[:answers] && params[:answers].values.reject{|x| [true,false].include?(x) || x.nil? || x.empty?}.blank?) # if a person has blank answers in a survey, destroy!
  end

  def get_person
    @person = current_person || Person.new
  end
end
