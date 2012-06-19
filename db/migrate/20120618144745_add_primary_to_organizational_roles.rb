class AddPrimaryToOrganizationalRoles < ActiveRecord::Migration
  def change
    add_column :organizational_roles, :primary, :boolean, default: false
  end
end
