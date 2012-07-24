class AddArchiveDateToOrganizationalRole < ActiveRecord::Migration
  def change
    add_column :organizational_roles, :archive_date, :datetime
  end
end
