class AddArchivedToElement < ActiveRecord::Migration
  def change
    add_column PageElement.table_name, :archived, :boolean, default: false
  end
end
