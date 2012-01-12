class AddTerminologyToSurveys < ActiveRecord::Migration
  def change
    add_column :mh_surveys, :terminology, :string, :default => 'Survey'
  end
end
