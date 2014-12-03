class CreateBulkMessages < ActiveRecord::Migration
  def change
    create_table :bulk_messages do |t|
      t.references :person
      t.references :organization
      t.string :status, default: "pending"

      t.timestamps
    end
    add_index :bulk_messages, :person_id
    add_index :bulk_messages, :organization_id
  end
end
