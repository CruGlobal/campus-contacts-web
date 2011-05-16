class AddStartAndEndDateToOrganizationMembership < ActiveRecord::Migration
  def change
    add_column :organization_memberships, :start_date, :date
    add_column :organization_memberships, :end_date, :date
  end
end
