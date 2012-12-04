class ImportsController < ApplicationController
  before_filter :get_import, only: [:show, :edit, :update, :destroy, :labels, :import]
  before_filter :init_org, only: [:index, :show, :edit, :update, :new, :labels, :import]
  rescue_from Import::NilColumnHeader, with: :nil_column_header

  def index
  end

  def show
  end

  def new
    @import = Import.new
    render layout: 'no_sidebar'
  end

  def create
    @import = current_user.imports.new(params[:import])
    @import.organization = current_organization
    begin
      if @import.save
        redirect_to edit_import_path(@import)
      else
        init_org
        render :new, layout: 'no_sidebar' 
      end      
    rescue ArgumentError
      flash.now[:error] = t('imports.new.wrong_file_format_error')
      init_org
      @import = Import.new
      render :new, layout: 'no_sidebar'
    end
  end

  def edit
    get_survey_questions
    render layout: 'no_sidebar'
  end
  
  def labels
    @import_count =  @import.get_new_people.count
    @roles = current_organization.roles
    render layout: 'no_sidebar'
  end

  def update
    columns_without_question = params[:import][:header_mappings].reject{|x,y| y.present? }
    if columns_without_question.count > 0
      survey_title = "Import-#{@import.created_at.strftime('%Y-%m-%d')}"
      unless @survey = current_organization.surveys.find_by_title(survey_title)
        @survey = current_organization.surveys.create(
          login_paragraph: I18n.t('application.survey.default_login_paragraph'),
          title: survey_title,
          post_survey_message: I18n.t('application.survey_name_field.default_post_survey_message'),
          terminology: 'Survey'
        )
      end
      columns_without_question.each do |column|
        question_label = @import.headers[column[0].to_i]
        unless @question = @survey.elements.find_by_label(question_label)
          @question = TextField.create!(style: 'short', label: question_label, content: params[:options], slug: '')
          @survey.elements << @question
        end
        @survey.survey_elements.find_by_element_id(@question.id).update_attribute(:hidden, true)
        params[:import][:header_mappings][column[0]] = @question.id.to_s
      end
    end
    
    @import.update_attributes(params[:import])
    errors = @import.check_for_errors

    if errors.present?
      flash.now[:error] = errors.join('<br />').html_safe
      init_org
      render :new, layout: 'no_sidebar'
    else
      redirect_to :action => :labels
    end
  end

  def import
    init_org
    if params[:use_labels] == '1' && params[:labels].present?
      @import.queue_import_contacts(params[:labels])
    else
      @import.queue_import_contacts([])
    end
    
    flash[:notice] = t('contacts.import_contacts.success')
    
    redirect_to controller: :contacts
  end
  

  #def destroy
  #  @import.destroy
  #  #redirect_to contacts_path
  #end

  def download_sample_contacts_csv
    csv_string = CSV.generate do |csv|
      c = 0
      CSV.foreach(Rails.root.to_s + "/public/files/import_contacts_template.csv") do |row|
        c = c + 1
        csv << row
      end
    end
    send_data csv_string, :type => 'text/csv; charset=UTF-8; header=present', :disposition => "attachment; filename=import_contacts_template.csv"
  end

  def nil_column_header
    init_org
    flash.now[:error] = t('contacts.import_contacts.blank_header')
    render :new
  end
  
  def create_survey_question
    unless params[:question_id].present?
      @message ||= "Enter new survey name." if params[:create_survey_toggle] == "new_survey" && !params[:survey_name_field].present?
      @message ||= "Select an existing survey." if params[:create_survey_toggle].blank? && !params[:select_survey_field].present?
      @message ||= "Select question type." unless params[:question_category].present?
    end
    @message ||= "Question can't be blank" unless params[:question].present?
    @message ||= "Choices can't be blank " if params[:question_category] == 'ChoiceField' && !params[:options].present?
    
    unless @message.present?
      
      if params[:question_id].present?
        @question = Element.find(params[:question_id])
        @question.update_attributes({label: params[:question], content: params[:options], slug: ''})
        @message = "UPDATE"
      else
        if params[:create_survey_toggle]
          @survey_status = 'NEW'
          @survey = current_organization.surveys.create(
            login_paragraph: I18n.t('application.survey.default_login_paragraph'),
            title: params[:survey_name_field],
            post_survey_message: I18n.t('application.survey_name_field.default_post_survey_message'),
            terminology: 'Survey'
          )
        else
          @survey = Survey.find(params[:select_survey_field].to_i)
          authorize! :manage, @survey
        end
        @question_category = params[:question_category]
        type, style = @question_category.split(':')
        @question = type.constantize.create!(style: style, label: params[:question], content: params[:options], slug: '')
      end
      
      unless @message == "UPDATE"
        if @survey.archived_questions.include?(@question)
          survey_element = SurveyElement.where(survey_id: @survey.id, element_id: @question.id).first
          survey_element.update_attribute(:archived, false)
        else
          begin
            @survey.elements << @question
            @survey.survey_elements.find_by_element_id(@question.id).update_attribute(:hidden, true)
            @message = "SUCCESS"
          rescue ActiveRecord::RecordInvalid => e
            @message = I18n.t('surveys.questions.create.duplicate_error')
          end
        end
      end
    end
    
  end

  protected

  def get_import
    @import = current_user.imports.where(organization_id: current_organization.id).find(params[:id])
  end

  def init_org
    @organization = current_organization
    org_ids = params[:subs] == 'true' ? @organization.self_and_children_ids : @organization.id
    @people_scope = Person.where('organizational_roles.organization_id' => org_ids).includes(:organizational_roles_including_archived)
    @people_scope = @people_scope.where(id: @people_scope.archived_not_included.collect(&:id)) if params[:include_archived].blank? && params[:archived].blank?
    
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

end
