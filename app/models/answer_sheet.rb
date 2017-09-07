class AnswerSheet < ActiveRecord::Base
  attr_accessible :completed_at, :person_id, :survey_id

  belongs_to :person
  belongs_to :survey
  has_many :answers, class_name: 'Answer', foreign_key: 'answer_sheet_id'

  def valid_person?
    (person.valid? && (!person.primary_phone_number || person.primary_phone_number.valid?))
  end

  def answers_by_question
    answers.group_by(&:question_id)
  end

  def save_survey(answers = nil, notify_on_predefined_questions = true)
    question_set = QuestionSet.new(survey.questions, self)
    question_set.post(answers, self) if answers
    return unless question_set.save(notify_on_predefined_questions)

    person&.touch
    update_attribute(:completed_at, Time.now)

    # Ensure that the user/contact will be added as contact in organization after taking survey
    survey.organization&.add_contact(person)
  end
end
