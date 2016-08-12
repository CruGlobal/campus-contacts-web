class AddIndexesOnOrganizationalPermissions < ActiveRecord::Migration
  def change
    add_index :organizational_permissions, [:permission_id, :organization_id, :archive_date, :deleted_at],
              name: 'index_organizational_permissions_ids'
  end
end
