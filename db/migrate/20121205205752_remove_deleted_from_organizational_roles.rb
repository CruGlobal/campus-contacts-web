class RemoveDeletedFromOrganizationalRoles < ActiveRecord::Migration
  def up
    OrganizationalRole.find_each do |ors|
      unless ors.archive_date
        if ors.deleted?
          ors.destroy
        else
          ors.update_attributes(archive_date: ors.end_date) if ors.end_date
        end
      end
    end

    remove_column :organizational_roles, :deleted
    remove_column :organizational_roles, :end_date
  end

  def down
    add_column :organizational_roles, :deleted, :boolean, default: false
    add_column :organizational_roles, :end_date, :date
  end
end
