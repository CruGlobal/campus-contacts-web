class AddDeletedAtToOrganizationalPermissions < ActiveRecord::Migration
  def change
    add_column :organizational_permissions, :deleted_at, :datetime
  end
end
