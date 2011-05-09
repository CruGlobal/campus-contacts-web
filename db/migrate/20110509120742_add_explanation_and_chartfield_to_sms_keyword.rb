class AddExplanationAndChartfieldToSmsKeyword < ActiveRecord::Migration
  def change
    add_column :sms_keywords, :chartfield, :string
    add_column :sms_keywords, :user_id, :integer
    add_column :sms_keywords, :explanation, :text
    add_column :sms_keywords, :state, :string
    rename_column :sms_keywords, :name, :keyword
  end
end