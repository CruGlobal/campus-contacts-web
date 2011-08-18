class AddWebOnlyToElement < ActiveRecord::Migration
  def change
    add_column Element.table_name, :web_only, :boolean, default: false
  end
end
