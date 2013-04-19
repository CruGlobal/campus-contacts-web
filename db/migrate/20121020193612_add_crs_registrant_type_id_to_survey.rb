class AddCrsRegistrantTypeIdToSurvey < ActiveRecord::Migration
  def change
    add_index :surveys, :crs_registrant_type_id

    add_column :elements, :crs_question_id, :integer
    add_index :elements, :crs_question_id
  end
end
