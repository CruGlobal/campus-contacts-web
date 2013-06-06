class Role < ActiveRecord::Base
end
class RenameRolesToPermissions < ActiveRecord::Migration
  def up
    Role.where('name IS NULL').destroy_all
    user = Role.where(i18n: 'missionhub_user').try(:first)
    user.update_attributes({name: 'User', i18n: 'user'}) if user.present?
    no_permission = Role.where(i18n: 'contact').try(:first)
    no_permission.update_attributes({name: 'No Permissions', i18n: 'no_permissions'}) if no_permission.present?
    archived = Role.where(i18n: 'archived').try(:first)
    archived.destroy if archived.present?
    
    rename_table :roles, :permissions
    remove_column :permissions, :organization_id
    rename_table :organizational_roles, :organizational_permissions
    rename_column :organizational_permissions, :role_id, :permission_id
  end

  def down
    rename_table :permissions, :roles
    add_column :roles, :organization_id, :integer, default: 0, after: 'id'
    rename_table :organizational_permissions, :organizational_roles
    rename_column :organizational_roles, :permission_id, :role_id
  end
end
