class QuestionRule < ActiveRecord::Base
  self.table_name = "mh_question_rules"
  attr_accessible :extra_parameters, :question_id, :rule_id, :trigger_keywords
  
  belongs_to :survey_element
  belongs_to :rule
end
