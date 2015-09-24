class CreateSignatures < ActiveRecord::Migration
  def change
    create_table :signatures do |t|
      t.references :person, index: true, foreign_key: true
      t.references :organization, index: true, foreign_key: true
      t.string :kind
      t.string :status

      t.timestamps null: false
    end
  end
end
