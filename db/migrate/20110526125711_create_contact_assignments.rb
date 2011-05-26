class CreateContactAssignments < ActiveRecord::Migration
  def change
    create_table :contact_assignments do |t|
      t.integer :assigned_to_id
      t.integer :person_id
      t.integer :question_sheet_id

      t.timestamps
    end
  end
end
