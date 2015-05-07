class RenameSurveyIdFromImports < ActiveRecord::Migration
  def up
    rename_column :imports, :survey_id, :survey_ids
    change_column :imports, :survey_ids, :text
  end

  def down
    rename_column :imports, :survey_ids, :survey_id
    change_column :imports, :survey_id, :integer
  end
end
