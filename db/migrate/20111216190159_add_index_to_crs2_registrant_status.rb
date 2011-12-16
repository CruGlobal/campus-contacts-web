class AddIndexToCrs2RegistrantStatus < ActiveRecord::Migration
  def change
    add_index :crs2_registrant, :status
  end
end