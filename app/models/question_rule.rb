class QuestionRule < ActiveRecord::Base
  self.table_name = "mh_question_rules"
  
  serialize :extra_parameters
  attr_accessible :extra_parameters, :question_id, :rule_id, :trigger_keywords, :survey_element_id
  
  belongs_to :survey_element
  belongs_to :rule
  
end
