class Survey < ActiveRecord::Base
  set_table_name 'mh_surveys'
  belongs_to :organization
end

class AnswerSheet < ActiveRecord::Base
  set_table_name "mh_answer_sheets"

  belongs_to :survey, :class_name => "Survey", :foreign_key => "survey_id"
end

class ChangePageElementsToSurveyElements < ActiveRecord::Migration
  def up
    rename_table :mh_page_elements, :mh_survey_elements
    rename_column :mh_survey_elements, :page_id, :survey_id
    add_column :mh_answer_sheets, :survey_id, :integer
    AnswerSheet.all.each do |as|
      survey = Survey.find_by_question_sheet_id(as.question_sheet_id)
      if survey
        as.update_column(:survey_id, survey.id)
      end
    end
    AnswerSheet.connection.update("update mh_answer_sheets set completed_at = updated_at where completed_at is null")
  end

  def down
    remove_column :mh_answer_sheets, :survey_id
    rename_column :mh_survey_elements, :survey_id, :page_id
    rename_table :mh_survey_elements, :mh_page_elements
  end
end