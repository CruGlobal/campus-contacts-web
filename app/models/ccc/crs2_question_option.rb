class Ccc::Crs2QuestionOption < ActiveRecord::Base
  establish_connection :uscm

  self.table_name = 'crs2_question_option'
  belongs_to :crs2_question, class_name: 'Ccc::Crs2Question', foreign_key: :option_question_id
end
