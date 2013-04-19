class AddSomeIndexes < ActiveRecord::Migration
  def change
    add_index :phone_numbers, :number
    add_index :survey_elements, [:survey_id, :element_id], name: 'survey_id_element_id'
    add_column :answer_sheets, :person_id, :integer
    add_index :answer_sheets, [:person_id, :survey_id], name: 'person_id_survey_id'
  end
end
