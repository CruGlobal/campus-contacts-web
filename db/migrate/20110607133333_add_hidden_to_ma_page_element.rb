class AddHiddenToMaPageElement < ActiveRecord::Migration
  def change
    add_column :ma_page_elements, :hidden, :boolean, :default => false
  end
end
