class Ccc::Crs2Question < ActiveRecord::Base
  set_table_name 'crs2_question'
  has_many :crs2_custom_questions_items, class_name: 'Ccc::Crs2CustomQuestionsItem'
  belongs_to :crs2_conference, class_name: 'Ccc::Crs2Conference', foreign_key: :conference_id
  has_many :crs2_question_options, class_name: 'Ccc::Crs2QuestionOption'
end
