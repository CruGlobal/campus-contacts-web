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
    if @import.save
      redirect_to edit_import_path(@import)
    else
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
      @import.get_new_people.each do |new_people|
        create_contact_from_row(new_people)
      end
      flash.now[:notice] = t('contacts.import_contacts.success')
      #render :show
      redirect_to :new
    else
      flash.now[:error] = errors.join('<br />').html_safe
      get_survey_questions
      render :edit
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
  end

  def create_contact_from_row(params)
    @organization ||= current_organization
    Person.transaction do
      params[:person] ||= {}
      params[:person][:email_address] ||= {}
      params[:person][:phone_number] ||= {}

      @person, @email, @phone = create_person(params[:person])
      if @person.save

        create_contact_at_org(@person, @organization)
        if params[:assign_to_me] == 'true'
          ContactAssignment.where(person_id: @person.id, organization_id: @organization.id).destroy_all
          ContactAssignment.create!(person_id: @person.id, organization_id: @organization.id, assigned_to_id: current_person.id)
        end

        @answer_sheets = []
        @organization ||= current_organization

        @organization.surveys.each do |survey|
          @answer_sheet = get_answer_sheet(survey, @person)
          question_set = QuestionSet.new(survey.questions, @answer_sheet)
          question_set.post(params[:answers], @answer_sheet)
          question_set.save
          @answer_sheets << @answer_sheet
        end

        return
      end
    end
  end

end
