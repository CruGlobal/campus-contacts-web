class AddSurveyIdToImports < ActiveRecord::Migration
  def change
    add_column :imports, :survey_id, :integer, after: "organization_id"
  end
end
