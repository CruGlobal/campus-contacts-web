class AddSkippedToPersonTransfer < ActiveRecord::Migration
  def change
    add_column :person_transfers, :skipped, :boolean, default: false, null: false
  end
end
