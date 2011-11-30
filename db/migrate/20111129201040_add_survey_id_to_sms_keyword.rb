class AddSurveyIdToSmsKeyword < ActiveRecord::Migration
  def change
    add_column :sms_keywords, :survey_id, :integer
    add_index :sms_keywords, :survey_id
    
    # Create surveys from current question_pages
  end
end