class AnswerSheet < ActiveRecord::Base

  belongs_to :person
  belongs_to :survey
  has_many :answers, :class_name => 'Answer', :foreign_key => 'answer_sheet_id'

  # def complete?
  #   !completed_at.nil?
  # end

  def valid_person?
    (person.valid? && (!person.primary_phone_number || person.primary_phone_number.valid?))
  end

  def answers_by_question
    self.answers.group_by { |answer| answer.question_id }
  end

  def save_survey(answers)
    question_set = QuestionSet.new(survey.questions, self)
    question_set.post(answers, self)
    question_set.save
    person.save
    update_attribute(:completed_at, Time.now)
  end

  # def has_answer_for?(question_id)
  #   answers_by_question[question_id].present?
  # end

end
