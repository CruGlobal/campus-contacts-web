class AddOrphanToCrs2Registrant < ActiveRecord::Migration
  def change
    add_column :crs2_registrant, :orphan, :boolean, default: false, null: false
  end
end