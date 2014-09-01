class AddResultsToBulkMessages < ActiveRecord::Migration
  def change
    add_column :bulk_messages, :results, :text, after: "status"
  end
end
