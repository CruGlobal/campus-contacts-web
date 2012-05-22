class AddTransferredByIdToMhPersonTransfers < ActiveRecord::Migration
  def change
    add_column :mh_person_transfers, :transferred_by_id, :integer
  end
end
