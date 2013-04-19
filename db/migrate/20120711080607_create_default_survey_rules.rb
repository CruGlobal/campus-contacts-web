class Rule < ActiveRecord::Base
end
class CreateDefaultSurveyRules < ActiveRecord::Migration
  def up
    rename_table :mh_rules, :rules
    Rule.create(
      name: 'Automatic Notification for Leaders',
      limit_per_survey: 0,
      rule_code: 'AUTONOTIFY'
    )
    Rule.create(
      name: 'Automatic Assignment of Contact',
      limit_per_survey: 0,
      rule_code: 'AUTOASSIGN'
    )
  end

  def down
  end
end
