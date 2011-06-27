class AddHiddenToMaPageElement < ActiveRecord::Migration
  def change
    add_column PageElement.table_name, :hidden, :boolean, default: false
  end
end
