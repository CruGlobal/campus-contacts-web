class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :organization_id
      t.integer :person_id
      t.integer :receiver_id
      t.string :from
      t.string :to
      t.string :subject
      t.text :message
      t.string :sent_via

      t.timestamps
    end
  end
end
