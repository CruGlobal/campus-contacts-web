class Rule < ActiveRecord::Base
  self.table_name = "mh_rules"
  attr_accessible :action_method, :description, :name
  
  has_many :question_rules
end
