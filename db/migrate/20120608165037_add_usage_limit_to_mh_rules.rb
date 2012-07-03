class AddUsageLimitToMhRules < ActiveRecord::Migration
  def change
    add_column :mh_rules, :limit_per_survey, :integer, default: 0
    add_column :mh_rules, :rule_code, :string
  end
end
