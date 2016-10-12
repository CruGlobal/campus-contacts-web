class Survey < ActiveRecord::Base
  NO_LOGIN = 3
  S3_CREDS = { bucket: ENV['AWS_BUCKET'], access_key_id: ENV['AWS_ACCESS_KEY_ID'], secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'] }

  attr_accessible :title, :organization_id, :copy_from_survey_id, :post_survey_message, :terminology,
                  :login_option, :is_frozen, :login_paragraph, :logo_file, :css_file, :css,
                  :background_color, :text_color, :crs_registrant_type_id, :redirect_url, :logo
  stores_emoji_characters :title, :terminology, :login_paragraph

  has_paper_trail on: [:destroy],
                  meta: { organization_id: :organization_id }

  belongs_to :organization

  has_many :custom_element_labels
  has_many :survey_elements,
           -> { order(:position) }, dependent: :destroy
  has_many :elements,
           -> { order(SurveyElement.table_name + '.position') }, through: :survey_elements, autosave: true, source: :question
  has_many :question_grid_with_totals,
           -> { where("kind = 'QuestionGridWithTotal'") }, through: :survey_elements, source: :question
  has_many :questions,
           -> { where("#{SurveyElement.table_name}.archived = 0").order("#{SurveyElement.table_name}.position") }, through: :survey_elements, source: :question
  has_many :archived_questions,
           -> { where("#{SurveyElement.table_name}.archived = 1").order("#{SurveyElement.table_name}.position") }, through: :survey_elements, source: :question
  has_many :all_questions,
           -> { order("#{SurveyElement.table_name}.position") }, through: :survey_elements, source: :question
  has_one :keyword, class_name: 'SmsKeyword', foreign_key: 'survey_id', dependent: :nullify

  has_attached_file :logo,
                    styles: { small: '300x' },
                    s3_credentials: S3_CREDS, storage: :s3, s3_protocol: :https,
                    path: 'surveys/:attachment/:style/:id/:filename', s3_storage_class: :reduced_redundancy
  has_attached_file :css_file,
                    s3_credentials: S3_CREDS, storage: :s3, s3_protocol: :https,
                    path: 'surveys/:attachment/:id/:filename', s3_storage_class: :reduced_redundancy
  has_many :answer_sheets
  has_many :rules, through: :survey_elements

  # validation
  validates_presence_of :title, :post_survey_message, :terminology
  validates_length_of :title, maximum: 100, allow_nil: true
  validates_attachment :logo, content_type: { content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif'] }

  default_value_for :terminology, 'Survey'

  def to_s
    title
  end

  def predefined_questions
    questions.where('object_name IS NOT NULL AND attribute_name IS NOT NULL')
  end

  # def questions_before_position(position)
  #   self.elements.where(["#{SurveyElement.table_name}.position < ?", position])
  # end

  # Include nested elements
  # def all_elements
  #   (elements + elements.collect(&:all_elements)).flatten
  # end

  def questions_with_answers(app = nil, person = nil)
    question_ids = []
    all_questions.each do |q|
      next if %w(email phone_number).include?(q.attribute_name)
      question_ids << q.id if q.display_response(app, person).present?
    end
    all_questions.where(id: question_ids)
  end

  def question_rules
    question_ids = questions.collect(&:id)
    element_ids = SurveyElement.where(element_id: question_ids).collect(&:id)
    question_rules = QuestionRule.where(survey_element_id: element_ids)
  end

  def has_assign_rule(type, extra_id = nil)
    rule_id = rules.find_by_rule_code('AUTOASSIGN').try(:id)
    return false unless rule_id
    rules = question_rules.where(rule_id: rule_id)
    rules.each do |rule|
      if rule.extra_parameters.present?
        if rule.extra_parameters['type'].downcase == type.downcase
          if extra_id.present?
            return true if rule.extra_parameters['id'].to_s == extra_id.to_s
          else
            return rule.extra_parameters['id']
          end
        end
      end
    end
    false
  end

  def has_assign_rule_applied(answer_sheet, type)
    rule_id = rules.find_by_rule_code('AUTOASSIGN')
    rules = question_rules.where(rule_id: rule_id)
    rules.each do |rule|
      element = rule.survey_element.element if rule.survey_element.present?
      answer = answer_sheet.answers.find_by_question_id(element.id) if element.present?
      triggers = rule.trigger_keywords.split(', ')
      if triggers.present? && element.present? && answer.present? && rule.extra_parameters.present?
        if rule.extra_parameters['type'].downcase == type.downcase
          return true if triggers.map(&:downcase).include?(answer.value.downcase)
        end
      end
    end
    false
  end

  def duplicate
    new_survey = Survey.new(attributes)
    new_survey.organization_id = organization_id
    new_survey.save(validate: false)
    elements.each do |element|
      if element.reuseable?
        SurveyElement.create(element: element, survey: new_survey)
      else
        element.duplicate(new_survey)
      end
    end
    new_survey
  end

  def duplicate_to_org(org, copy_answers = false, person = nil)
    survey = org.surveys.find_by_copy_from_survey_id(id)

    # Copy the survey
    unless survey.present?
      survey = dup
      survey.organization = org
      survey.copy_from_survey_id = id
      survey.save(validate: false)
    end

    # Copy the answer_sheet
    if copy_answers && person.present?
      if answer_sheet = person.answer_sheets.find_by_survey_id(id)
        new_answer_sheet = person.answer_sheets.find_by_survey_id(survey.id)
        unless new_answer_sheet.present?
          new_answer_sheet = answer_sheet.dup
          new_answer_sheet.completed_at = answer_sheet.completed_at
          new_answer_sheet.survey_id = survey.id
          new_answer_sheet.save
        end
      end
    end

    elements.each do |element|
      # Copy the elements
      new_element = survey.elements.find_by_id(element.id)
      unless new_element.present?
        if element.predefined? || element.reuseable?
          SurveyElement.create(element: element, survey: survey)
          new_element = element
        else
          new_element = element.duplicate(survey)
        end
      end

      # Copy the answers
      if new_element.present? && new_answer_sheet.present? && copy_answers
        if answers = answer_sheet.answers.where(question_id: element.id)
          new_answer = new_answer_sheet.answers.find_by_question_id(new_element.id)
          unless new_answer.present?
            answers.each do |answer|
              new_answer = answer.dup
              new_answer.update(question_id: new_element.id, answer_sheet_id: new_answer_sheet.id)
            end
          end
        end
      end
    end
    survey
  end

  def questions=(questions_attributes)
    current_question_ids = new_record? ? [] : questions.pluck('elements.id')
    questions_attributes.each do |question|
      question_attributes = question['question'] ? question['question'] : question
      if question_attributes['id']
        survey_elements.new(element_id: question_attributes['id']) unless current_question_ids.include?(question_attributes['id'].to_i)
      else
        q = question_attributes.delete('kind').constantize.create(question_attributes)
        survey_elements.new(element_id: q.id)
      end
    end
  end

  def convert_all_answer_sheets_to_notes
    eager_loaded_sheets = answer_sheets.includes({ person: [:interactions] }, :answers).where.not(people: { id: nil })
    eager_loaded_sheets.find_each do |as|
      as.to_note.save! unless as.existing_note
    end
  end
end
