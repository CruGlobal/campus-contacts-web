class AddBulkMessageToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :bulk_message_id, :integer, after: "id"
    add_index :messages, :bulk_message_id
  end
end
