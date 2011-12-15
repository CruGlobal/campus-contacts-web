class AddPostSurveyMessageToMhSurvey < ActiveRecord::Migration
  def up
    add_column :mh_surveys, :post_survey_message, :text
    SmsKeyword.where("survey_id is not null").each do |keyword|
      keyword.survey.update_column(:post_survey_message, keyword.post_survey_message)
    end
    rename_column :sms_keywords, :post_survey_message, :post_survey_message_deprecated
  end
  
  def down
    remove_column :mh_surveys, :post_survey_message
    rename_column :sms_keywords, :post_survey_message_deprecated, :post_survey_message
  end
end
