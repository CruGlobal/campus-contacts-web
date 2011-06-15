class RenameMaTablesToMh < ActiveRecord::Migration
  def change
    rename_table :ma_answer_sheets, :mh_answer_sheets
    rename_table :ma_answers, :mh_answers
    rename_table :ma_conditions, :mh_conditions
    rename_table :ma_elements, :mh_elements
    rename_table :ma_email_templates, :mh_email_templates
    rename_table :ma_page_elements, :mh_page_elements
    rename_table :ma_pages, :mh_pages
    rename_table :ma_question_sheets, :mh_question_sheets
    rename_table :ma_references, :mh_references
  end

end