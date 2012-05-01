class CreateImports < ActiveRecord::Migration
  def change
    create_table :mh_imports do |t|
      t.belongs_to :user
      t.belongs_to :organization
      t.has_attached_file :upload
      t.text :headers # Array
      t.text :header_mappings # Hash

      t.timestamps
    end
    add_index :mh_imports, [:user_id, :organization_id], name: 'user_org'
    add_index :mh_imports, :organization_id
  end
end
