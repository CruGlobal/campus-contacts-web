class AddPostSurveyMessageToMhSurvey < ActiveRecord::Migration
  def up
    rename_column :sms_keywords, :post_survey_message, :post_survey_message_deprecated
  end

  def down
    rename_column :sms_keywords, :post_survey_message_deprecated, :post_survey_message
  end
end
