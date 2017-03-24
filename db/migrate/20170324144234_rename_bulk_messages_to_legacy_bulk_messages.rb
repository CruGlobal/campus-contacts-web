class RenameBulkMessagesToLegacyBulkMessages < ActiveRecord::Migration
  def change
    rename_table :bulk_messages, :legacy_bulk_messages
    rename_index :legacy_bulk_messages, 'index_bulk_messages_on_person_id', 'index_legacy_bulk_messages_on_person_id'
    rename_index :legacy_bulk_messages, 'index_bulk_messages_on_organization_id', 'index_legacy_bulk_messages_on_organization_id'
  end
end
