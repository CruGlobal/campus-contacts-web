class QuestionRule < ActiveRecord::Base
  
  serialize :extra_parameters
  attr_accessible :extra_parameters, :question_id, :rule_id, :trigger_keywords, :survey_element_id
  
  belongs_to :survey_element
  belongs_to :rule
  
end
