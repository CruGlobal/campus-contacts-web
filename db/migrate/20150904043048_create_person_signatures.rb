class CreatePersonSignatures < ActiveRecord::Migration
  def change
    create_table :person_signatures do |t|
      t.references :person, index: true, foreign_key: true
      t.references :organization, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
