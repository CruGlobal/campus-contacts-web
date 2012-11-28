class CreateSentPeople < ActiveRecord::Migration
  def change
    create_table :sent_people do |t|
      t.integer :person_id
      t.integer :transferred_by_id

      t.timestamps
    end
  end
end
