class RemoveQuestionSheetIdFromMhSurveysAndMhAnswerSheets < ActiveRecord::Migration
  def up
    remove_column :answer_sheets, :question_sheet_id
  end

  def down
  end
end
