class AddSurveyIdIndexToAnswerSheets < ActiveRecord::Migration
  def change
    add_index :answer_sheets, :survey_id
  end
end
