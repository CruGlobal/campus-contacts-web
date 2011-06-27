class AddImportableToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :importable_id, :integer
    add_column :organizations, :importable_type, :string
    add_index :organizations, [:importable_type, :importable_id], unique: true
  end
end