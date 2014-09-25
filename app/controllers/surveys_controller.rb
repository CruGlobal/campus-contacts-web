class SurveysController < ApplicationController
  before_filter :set_keyword_cookie, only: :start
  before_filter :prepare_for_mobile, only: [:start, :stop, :index]
  skip_before_filter :authenticate_user!
  skip_before_filter :check_url
  load_and_authorize_resource except: [:start, :stop, :index]

  require 'api_helper'
  include ApiHelper

  def index_admin
    @organization = current_person.organization_from_id(params[:org_id]) || current_organization
    authorize! :manage, @organization
    @surveys = @organization.surveys.includes(:keyword)
  end
  
  def mass_entry
    render 'mass_entry', layout: 'mass_entry'
  end
  
  def mass_entry_data
    @people = current_organization.not_archived_people.who_answered(@survey.id)
    questions = @survey.questions.order(:position)
    
    # Collect survey settings
    settings = Array.new
    # settings << {data: "id", type: "text", readOnly: true}
    settings << {data: "first_name", type: "text", readOnly: true}
    settings << {data: "last_name", type: "text", readOnly: true}
    settings << {data: "phone_number", type: "text", readOnly: true}
    questions.each do |question|
      setting = Hash.new
      setting["data"] = question.id
      setting["allowInvalid"] = false
      setting["readOnly"] = question.predefined?
      case question.kind
      when "ChoiceField"
        if question.style == "radio"
          setting["type"] = "dropdown"
          setting["strict"] = "false"
          setting["source"] = question.options_with_blank
        elsif question.style == "drop-down"
          setting["type"] = "dropdown"
          setting["strict"] = "false"
          setting["source"] = question.options_with_blank
        else
          setting["editor"] = "multiselect"
          setting["strict"] = "false"
          setting["selectOptions"] = question.options_with_blank
        end
      when "DateField"
        setting["type"] = "date"
        setting["dateFormat"] = "yy-mm-dd"
      when "TextField"
      end
      settings << setting
    end
    
    # Collect survey questions & answers
    data = Array.new
    @people.each do |person|
      values = Hash.new
      answer_sheet = person.answer_sheet_for_survey(@survey.id)
      values["id"] = person.id
      values["first_name"] = person.first_name
      values["last_name"] = person.last_name
      values["phone_number"] = person.pretty_phone_number
      questions.each do |question|
        if question.predefined?
          if ['faculty'].include?(question.attribute_name)
            values[question.id] = person.send(question.attribute_name) ? "Yes" : "No"
          else
            values[question.id] = person.send(question.attribute_name) || ""
          end
        else
          if answer = answer_sheet.answers.where(question_id: question.id).first
            values[question.id] = answer.value || ""
          else
            values[question.id] = ""
          end
        end
      end
      data << values
    end
    response = Hash.new
    response['headers'] = ["First Name", "Last Name", "Phone Number"] + questions.collect(&:label)
    response['settings'] = settings
    response['data'] = data
    render json: response.to_json
  end
  
  def mass_entry_save
    @msg = Array.new
    return false unless params["values"].present?
    @people = current_organization.not_archived_people.who_answered(@survey.id)
    questions = @survey.questions.order(:position)
    updated_ids = []
    params["values"].values.each_with_index do |value, i|
      value.keys.each{|k| value[k] = nil if value[k] == "null"}
      if value["id"].nil?
        # Try to create new record
        if value["first_name"].present? || value["last_name"].present?
          if value["first_name"] && value["last_name"].present?
            # Create record
            email_question = Element.find_by_attribute_name("email")
            email = value[email_question.id.to_s] if email_question.present?
            if email.present?
              # Save w/o email
              person = EmailAddress.where(email: email).first.try(:person)
              if person
                # Existing person
                person.update_from_survey_answers(@survey, current_organization, questions, value, current_person, true)
              else
                # New person
                person = Person.create(first_name: value['first_name'], last_name: value['last_name'], email: email)
                person.update_from_survey_answers(@survey, current_organization, questions, value, current_person, true)
              end
            else
              if value["phone_number"].present?
                # See if we can match someone by name and phone number
                person = Person.find_existing_person_by_name_and_phone(number: value["phone_number"], first_name: value["first_name"], last_name: value["last_name"])
                if person
                  # Existing person
                  person.update_from_survey_answers(@survey, current_organization, questions, value, current_person, true)
                else
                  # New person
                  person = Person.create(first_name: value['first_name'], last_name: value['last_name'], email: email, phone_number: value["phone_number"])
                  person.update_from_survey_answers(@survey, current_organization, questions, value, current_person, true)
                end
              else
                # Save w/o email
                person = Person.create(first_name: value['first_name'], last_name: value['last_name'])
                person.update_from_survey_answers(@survey, current_organization, questions, value, current_person, true)
              end
            end
          else
            @msg << " - Row##{i + 1}: First and last names are required."
          end
        end
      else
        person = @people.find(value["id"])
        person.update_from_survey_answers(@survey, current_organization, questions, value, current_person, true)
      end
      updated_ids << person.id if person.present?
    end
    @survey.answer_sheets.where("person_id NOT IN (?)", updated_ids).destroy_all if @msg == []
  end

  def index
    # authenticate_user! unless params[:access_token] && params[:org_id]
    @title = "Pick A Survey"
    if current_user
      @organization = current_person.organization_from_id(params[:org_id]) || current_organization
      @surveys = @organization ? @organization.self_and_children_surveys : nil

      respond_to do |wants|
        wants.html { render 'index_admin' }
        wants.mobile
      end
    else
      return render_404
    end
  end

  def edit

  end

  def new

  end

  def destroy
    @survey.destroy
    respond_to do |wants|
      wants.html { redirect_to :back }
      wants.js {render :nothing => true}
    end
  end

  def remove_logo
    @survey = current_organization.surveys.find_by_id(params[:id])
    msg = I18n.t('surveys.form.remove_logo_failed')
    if @survey.present?
      @survey.logo.destroy if @survey.logo.exists?
      if @survey.save
        msg = I18n.t('surveys.form.remove_logo_success')
      end
    end
    redirect_to :back, notice: msg
  end

  def show_other_orgs
    org_ids = (current_person.admin_of_org_ids - [current_organization.id]).uniq
    @managed_orgs = Organization.where(id: org_ids)
    if params[:keyword]
      @managed_orgs = @managed_orgs.where("name LIKE ? OR name = ?","%#{params[:keyword]}%", params[:keyword])
    end
    @managed_orgs = @managed_orgs.order('name')
  end

  def copy_survey
    @survey = current_organization.surveys.find(params[:survey_id])
    @receiving_org = Organization.find(params[:organization_id])
    @status = 'failed'

    if @survey && @receiving_org
      if @receiving_org.surveys.where(title: @survey.title).present?
        @status = 'duplicate'
      else
        new_survey = @receiving_org.surveys.new(@survey.attributes)
        if new_survey.save
          @survey.survey_elements.each do |q|
            if element = q.element
              new_element = element.kind.constantize.create(element.attributes.except("id","kind"))
              new_question = new_survey.survey_elements.new(q.attributes.merge("element_id" => new_element.id))
              new_question.save
            end
          end
          @status = 'copied'
        end
      end
    end
  end

  def update
    if @survey.update_attributes(params[:survey])
      redirect_to index_admin_surveys_path
    else
      render :edit
    end
  end

  def create
    @survey = current_organization.surveys.new(params[:survey])
    if @survey.save
      redirect_to index_admin_surveys_path
    else
      current_organization.surveys -= [@survey]
      render :new
    end
  end

  # Enter survey mode
  def start
    unless mhub? #|| Rails.env.test?
      redirect_to start_survey_url(@survey, protocol: 'https', host: APP_CONFIG['public_host'], port: APP_CONFIG['public_port'])
      return false
    end
    cookies[:survey_mode] = 1
    redirect_to sign_out_url(protocol: 'https', next: short_survey_url(@survey.id, protocol: 'https'))
    #redirect_to short_survey_url(@survey.id)
  end

  # Exit survey mode
  def stop
    cookies[:survey_mode] = nil
    cookies[:keyword] = nil
    cookies[:survey_id] = nil
    redirect_to(request.referrer ? :back : 'https://www.missionhub.com')
  end


end
