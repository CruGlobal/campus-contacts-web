class AddCopyFromSurveyIdToSurveys < ActiveRecord::Migration
  def change
    add_column :surveys, :copy_from_survey_id, :integer, after: 'organization_id'
  end
end