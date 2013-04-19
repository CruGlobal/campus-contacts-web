class AddSurveyIdToSmsKeyword < ActiveRecord::Migration
  def up
    add_column :sms_keywords, :survey_id, :integer
    add_index :sms_keywords, :survey_id
    add_index :surveys, :organization_id
  end

  def down
    remove_index :surveys, :organization_id
    remove_column :sms_keywords, :survey_id
    remove_index :sms_keywords, :survey_id
  end
end