class Ccc::Crs2Question < ActiveRecord::Base
  establish_connection :uscm

  self.table_name = 'crs2_question'
  self.inheritance_column = 'fake'
  has_many :custom_questions_items, class_name: 'Ccc::Crs2CustomQuestionsItem', foreign_key: :question_id
  belongs_to :conference, class_name: 'Ccc::Crs2Conference', foreign_key: :conference_id
  has_many :question_options, class_name: 'Ccc::Crs2QuestionOption', foreign_key: :option_question_id
end
