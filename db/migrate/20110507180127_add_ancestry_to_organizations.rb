class AddAncestryToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :ancestry, :string
    add_column :organizations, :terminology, :string
    add_index :organizations, :ancestry
  end

  def self.down
    remove_index :organizations, :ancestry
    remove_column :organizations, :terminology
    remove_column :organizations, :ancestry
  end
end