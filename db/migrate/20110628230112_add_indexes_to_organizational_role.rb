class AddIndexesToOrganizationalRole < ActiveRecord::Migration
  def change
    add_index :organizational_roles, [:person_id, :organization_id, :role_id], :name => "person_role_org", :unique => true
  end
end