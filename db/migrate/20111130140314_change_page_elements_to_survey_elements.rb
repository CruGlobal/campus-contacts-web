class ChangePageElementsToSurveyElements < ActiveRecord::Migration
  def up
    rename_table :page_elements, :survey_elements
    rename_column :survey_elements, :page_id, :survey_id
    add_column :answer_sheets, :survey_id, :integer
  end

  def down
    remove_column :answer_sheets, :survey_id
    rename_column :survey_elements, :survey_id, :page_id
    rename_table :survey_elements, :mh_page_elements
  end
end