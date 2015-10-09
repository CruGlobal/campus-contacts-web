class Rule < ActiveRecord::Base
  attr_accessible :action_method, :description, :name, :limit_per_survey, :rule_code

  has_many :question_rules

  def self.available_in_survey(survey)
    rules = []
    all_rules = Rule.where.not(name: nil)
    if survey.rules.present?
      all_rules.each do |rule|
        existence = survey.rules.where(id: rule.id).count
        if rule.limit_per_survey == 0 || existence < rule.limit_per_survey
          rules << rule
        end
      end
    else
      rules = all_rules
    end
    rules
  end
end
