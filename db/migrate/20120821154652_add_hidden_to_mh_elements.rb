class AddHiddenToMhElements < ActiveRecord::Migration
  def change
    add_column :mh_elements, :hidden, :boolean, default: false, null: false
  end
end
