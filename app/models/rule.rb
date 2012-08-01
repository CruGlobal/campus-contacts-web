class Rule < ActiveRecord::Base
  self.table_name = "mh_rules"
  attr_accessible :action_method, :description, :name, :limit_per_survey, :rule_code
  
  has_many :question_rules
  
  
  def self.available_in_survey(survey)
    rules = Array.new
    all_rules = Rule.all
    if survey.rules.present?
      all_rules.each do |rule|
        existence = survey.rules.where(id: rule.id).count
        rules << rule if rule.limit_per_survey == 0 || existence < rule.limit_per_survey
      end
    else
      rules = all_rules
    end
    rules
  end
  
end
