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
    multi_col = Array.new
    # settings << {data: "id", type: "text", readOnly: true}
    settings << {data: "first_name", type: "text", readOnly: true}
    settings << {data: "last_name", type: "text", readOnly: true}
    settings << {data: "phone_number", type: "text", readOnly: true}
    
    multi_col << 3
    setting = Hash.new
    setting["data"] = "labels"
    setting["allowInvalid"] = false
    setting["readOnly"] = false
    setting["editor"] = "select"
    setting["strict"] = "false"
    setting["selectOptions"] = current_organization.labels.collect(&:name)
    settings << setting
    
    questions.each_with_index do |question, index|
      i = index + 4
      setting = Hash.new
      setting["data"] = question.id
      setting["allowInvalid"] = false
      setting["readOnly"] = question.predefined?
      case question.kind
      when "ChoiceField"
        if question.style == "radio"
          setting["type"] = "dropdown"
          setting["strict"] = "false"
          setting["source"] = question.options
        elsif question.style == "drop-down"
          setting["type"] = "dropdown"
          setting["strict"] = "false"
          setting["source"] = question.options
        else
          multi_col << i
          setting["editor"] = "select"
          setting["strict"] = "false"
          setting["selectOptions"] = question.options
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
      values["labels"] = person.labels_for_org_id(current_organization.id).collect(&:name).join(",  ")
      questions.each do |question|
        if question.predefined?
          if ['faculty'].include?(question.attribute_name)
            values[question.id] = person.send(question.attribute_name) ? "Yes" : "No"
          else
            values[question.id] = person.send(question.attribute_name) || ""
          end
        else
          if question.style == "checkbox"
            values[question.id] = answer_sheet.answers.where(question_id: question.id).collect(&:value).join(",  ")
          else
            if answer = answer_sheet.answers.where(question_id: question.id).first
              values[question.id] = answer.value || ""
            else
              values[question.id] = ""
            end
          end
        end
      end
      data << values
    end
    response = Hash.new
    response['headers'] = ["First Name", "Last Name", "Phone Number", "Labels"] + questions.collect(&:label)
    response['settings'] = settings
    response['multi_col'] = multi_col
    response['data'] = data
    render json: response.to_json
  end
  
  def create_label
    @status = "false"
    if params[:name].present?
      if Label.where("organization_id IN (?) AND LOWER(name) = ?", [current_organization.id,0], params[:name].downcase).present?
        @msg_alert = t('contacts.index.add_label_exists2')
      else
        @new_label = Label.create(organization_id: current_organization.id, name: params[:name]) if params[:name].present?
        if @new_label.present?
          @status = "true"
          @msg_alert = t('contacts.index.add_label_success')
        else
          @msg_alert = t('contacts.index.add_label_failed')
        end
      end
    else
      @msg_alert = t('contacts.index.add_label_empty')
    end
  end

  def mass_entry_save
    @msg = Array.new
    return false unless params["values"].present?
    @people = current_organization.not_archived_people.who_answered(@survey.id)
    questions = @survey.questions.order(:position)
    updated_ids = []
    params["values"].values.each_with_index do |value, i|
      value.keys.each{|k| value[k] = nil if value[k] == "null"}
      if params["new_label_to_all"].present?
        labels = value["labels"].split(",  ")
        labels += [params['new_label_to_all']]
        value["labels"] = labels.join(",  ")
      end
      if value["id"].nil?
        # Try to create new record
        if params["new_label_to_new"].present?
          labels = value["labels"].split(",  ")
          labels += [params['new_label_to_new']]
          value["labels"] = labels.join(",  ")
        end
        if value["first_name"].present? || value["last_name"].present?
          if value["first_name"] && value["last_name"].present?
            # Create record
            email_question = Element.find_by_attribute_name("email")
            email = value[email_question.id.to_s] if email_question.present?
            number = PhoneNumber.strip_us_country_code(value["phone_number"].to_s)
            if email.present?
              # Save w/o email
              if EmailAddress.new(email: email).valid?
                person = EmailAddress.where(email: email).first.try(:person)
                if person
                  # Existing person
                  person.update_from_survey_answers(@survey, current_organization, questions, value, current_person, true, true)
                else
                  # New person
                  person = Person.create(first_name: value['first_name'], last_name: value['last_name'], email: email)
                  person.update_from_survey_answers(@survey, current_organization, questions, value, current_person, true, true)
                end
                person.phone_number = number
                person.save
              else
                @msg << " - Row##{i + 1}: Invalid email address format."
              end
            else
              if value["phone_number"].present?
                # See if we can match someone by name and phone number
                if PhoneNumber.new(number: number).valid?
                  person = Person.find_existing_person_by_name_and_phone(number: number, first_name: value["first_name"], last_name: value["last_name"])
                  if person
                    # Existing person
                    person.update_from_survey_answers(@survey, current_organization, questions, value, current_person, true, true)
                  else
                    # New person
                    person = Person.create(first_name: value['first_name'], last_name: value['last_name'], email: email, phone_number: number)
                    person.update_from_survey_answers(@survey, current_organization, questions, value, current_person, true, true)
                  end
                else
                  @msg << " - Row##{i + 1}: Invalid phone number."
                end
              else
                # Save w/o email
                person = Person.create(first_name: value['first_name'], last_name: value['last_name'])
                person.update_from_survey_answers(@survey, current_organization, questions, value, current_person, true, true)
              end
            end
          else
            @msg << " - Row##{i + 1}: First and last names are required."
          end
        end
      else
        person = @people.find(value["id"])
        person.update_from_survey_answers(@survey, current_organization, questions, value, current_person, true, true)
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
        if @survey.duplicate_to_org(@receiving_org)
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
    protocol = Rails.env.development? ? 'http' : 'https'
    unless mhub? #|| Rails.env.test?
      redirect_to start_survey_url(@survey, protocol: protocol, host: APP_CONFIG['public_host'], port: APP_CONFIG['public_port'])
      return false
    end
    cookies[:survey_mode] = "1"
    redirect_to sign_out_url(protocol: protocol, next: short_survey_url(@survey.id, protocol: protocol))
    # redirect_to short_survey_url(@survey.id)
  end

  # Exit survey mode
  def stop
    cookies[:survey_mode] = nil
    cookies[:keyword] = nil
    cookies[:survey_id] = nil
    home_url = Rails.env.development? ? 'http://local.missionhub.com:7888' : 'https://www.missionhub.com'
    redirect_to(request.referrer ? :back : home_url)
  end


end
