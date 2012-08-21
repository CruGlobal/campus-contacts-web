class ImportsController < ApplicationController
  before_filter :get_import, only: [:show, :edit, :update, :destroy]
  before_filter :init_org, only: [:index, :show, :edit, :update, :new]
  rescue_from Import::NilColumnHeader, with: :nil_column_header

  def index
  end

  def show
  end

  def new
    @import = Import.new
  end

  def create
    @import = current_user.imports.new(params[:import])
    @import.organization = current_organization
    begin
      if @import.save
        redirect_to edit_import_path(@import)
      else
        init_org
        render :new
      end
    rescue ArgumentError => e
      flash.now[:error] = t('imports.new.wrong_file_format_error')
      init_org
      @import = Import.new
      render :new
    end
  end

  def edit
    get_survey_questions
  end

  def update
    @import.update_attributes(params[:import])
    errors = @import.check_for_errors

    if errors.blank?
      Person.transaction do
        @import.get_new_people.each do |new_person|
          person = create_contact_from_row(new_person)
          if person.errors.present?
            errors << "#{person.to_s}: #{person.errors.full_messages.join(', ')}"
          end
        end
        raise ActiveRecord::Rollback if errors.present?
      end
    end

    if errors.present?
      flash.now[:error] = errors.join('<br />').html_safe
      init_org
      render :new
    else
      flash[:notice] = t('contacts.import_contacts.success')
      redirect_to contacts_path and return
    end
  end

  def destroy
    @import.destroy
    redirect_to contacts_path
  end

  def download_sample_contacts_csv
    csv_string = CSV.generate do |csv|
      c = 0
      CSV.foreach(Rails.root.to_s + "/public/files/sample_contacts.csv") do |row|
        c = c + 1
        csv << row
      end
    end
    send_data csv_string, :type => 'text/csv; charset=UTF-8; header=present', :disposition => "attachment; filename=sample_contacts.csv"
  end

  def nil_column_header
    init_org
    flash.now[:error] = t('contacts.import_contacts.blank_header')
    render :new
  end

  protected

  def get_import
    @import = current_user.imports.where(organization_id: current_organization.id).find(params[:id])
  end

  def init_org
    @organization = current_organization
    authorize! :manage, @organization
  end

  def get_survey_questions
    @survey_questions = Hash.new
    current_organization.surveys.each do |survey|
      @survey_questions[survey.title] = Hash.new
      survey.all_questions.each do |q|
        @survey_questions[survey.title][q.label] = q.id
      end
    end
    @survey_questions[I18n.t('surveys.questions.index.predefined')] = Survey.find(APP_CONFIG['predefined_survey']).questions.collect { |q| [q.label, q.id] }
  end

  def create_contact_from_row(row)

    person = Person.new

    unless @surveys_for_import
      @survey_ids ||= SurveyElement.where(element_id: row[:answers].keys).pluck(:survey_id) - [APP_CONFIG['predefined_survey']]
      @surveys_for_import = current_organization.surveys.where(id: @survey_ids.uniq)
    end

    question_sets = []

    @surveys_for_import.each do |survey|
      answer_sheet = get_answer_sheet(survey, person)
      question_set = QuestionSet.new(survey.questions, answer_sheet)
      question_set.post(row[:answers], answer_sheet)
      question_sets << question_set
    end

    # Set values for predefined questions
    answer_sheet = AnswerSheet.new(person: person)
    predefined =
      begin
        Survey.find(APP_CONFIG['predefined_survey'])
      rescue
        Survey.find(2)
      end
    predefined.elements.where('object_name is not null').each do |question|
      question.set_response(row[:answers][question.id], answer_sheet)
    end

    person, email, phone = Person.find_existing_person(person)

    if person.save
      question_sets.map { |qs| qs.save }
      create_contact_at_org(person, current_organization)
    end

    return person
  end

end
