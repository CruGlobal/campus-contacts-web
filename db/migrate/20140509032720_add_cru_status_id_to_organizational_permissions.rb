class AddCruStatusIdToOrganizationalPermissions < ActiveRecord::Migration
  def change
    add_column :organizational_permissions, :cru_status_id, :integer, after: 'organization_id'
    remove_column :people, :cru_status_id
  end
end
