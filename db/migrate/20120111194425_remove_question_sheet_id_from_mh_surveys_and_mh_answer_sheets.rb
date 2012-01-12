class RemoveQuestionSheetIdFromMhSurveysAndMhAnswerSheets < ActiveRecord::Migration
  def up
    remove_column :mh_surveys, :question_sheet_id
    remove_column :mh_answer_sheets, :question_sheet_id    
  end

  def down
  end
end
