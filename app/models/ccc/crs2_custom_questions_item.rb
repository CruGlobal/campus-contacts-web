class Ccc::Crs2CustomQuestionsItem < ActiveRecord::Base
  set_table_name 'crs2_custom_questions_item'
  has_many :crs2_answers, :class_name => 'Ccc::Crs2Answer'
  belongs_to :crs2_question, :class_name => 'Ccc::Crs2Question', :foreign_key => :question_id
  belongs_to :crs2_registrant_type, :class_name => 'Ccc::Crs2RegistrantType', :foreign_key => :registrant_type_id
end
