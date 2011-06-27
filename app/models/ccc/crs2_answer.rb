class Ccc::Crs2Answer < ActiveRecord::Base
  set_table_name 'crs2_answer'
  belongs_to :crs2_custom_questions_item, class_name: 'Ccc::Crs2CustomQuestionsItem', foreign_key: :question_usage_id
  belongs_to :crs2_registrant, class_name: 'Ccc::Crs2Registrant', foreign_key: :registrant_id
end
