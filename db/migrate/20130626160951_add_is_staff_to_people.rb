class AddIsStaffToPeople < ActiveRecord::Migration
  def change
    add_column :people, :is_staff, :boolean, default: false, null: false
  end
end
