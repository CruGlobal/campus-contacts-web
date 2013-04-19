class CreateNewSurveys < ActiveRecord::Migration
  def change

    create_table :surveys do |t|
      t.string   "title",                  :limit => 100,  :default => "",       :null => false
      t.integer  "organization_id"
      t.text     "post_survey_message"
      t.string   "terminology",                            :default => "Survey"
      t.integer  "login_option",                           :default => 0
      t.boolean  "is_frozen"
      t.text     "login_paragraph"
      t.string   "logo_file_name"
      t.string   "logo_content_type"
      t.integer  "logo_file_size"
      t.datetime "logo_updated_at"
      t.string   "css_file_file_name"
      t.string   "css_file_content_type"
      t.integer  "css_file_file_size"
      t.datetime "css_file_updated_at"
      t.text     "css"
      t.string   "background_color"
      t.string   "text_color"
      t.integer  "crs_registrant_type_id"
      t.string   "redirect_url",           :limit => 2000
      t.timestamps
    end
  end
end
