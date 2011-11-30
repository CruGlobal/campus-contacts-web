class AnswerSheet < ActiveRecord::Base
  set_table_name "mh_answer_sheets"

  belongs_to :person
  belongs_to :survey
  has_many :answers, :class_name => 'Answer', :foreign_key => 'answer_sheet_id'

  def complete?
    !completed_at.nil?
  end
  
  def answers_by_question
    self.answers.group_by { |answer| answer.question_id }
  end
  
  def has_answer_for?(question_id)
    answers_by_question[question_id].present?
  end
  
end
