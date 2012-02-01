class AddAddedByIdToOrganizationalRole < ActiveRecord::Migration
  def change
    add_column :organizational_roles, :added_by_id, :integer
  end
end
