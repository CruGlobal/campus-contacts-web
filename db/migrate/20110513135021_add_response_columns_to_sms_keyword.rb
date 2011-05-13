class AddResponseColumnsToSmsKeyword < ActiveRecord::Migration
  def change
    add_column :sms_keywords, :initial_response, :string, :limit => 140, :default => "Hi! Thanks for checking out Cru. Visit {{ link }} to get more involved."
    add_column :sms_keywords, :post_survey_message, :text
  end
end
