class AddSomeIndexes < ActiveRecord::Migration
  def change
    add_index :ministry_person, [:firstName, :lastName], name: 'firstName_lastName'
    remove_index :ministry_person, name: 'firstname_ministry_Person'
    add_index :phone_numbers, :number
    add_index :mh_survey_elements, [:survey_id, :element_id], name: 'survey_id_element_id'
    add_index :mh_answer_sheets, [:person_id, :survey_id], name: 'person_id_survey_id'
  end
end
