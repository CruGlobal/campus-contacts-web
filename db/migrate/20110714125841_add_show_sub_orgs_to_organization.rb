class AddShowSubOrgsToOrganization < ActiveRecord::Migration
  def up
    add_column :organizations, :show_sub_orgs, :boolean, default: false, null: false
    Organization.update_all('show_sub_orgs = 1', "terminology = 'Missional Team'")
  end
  
  def down
    remove_column :organizations, :show_sub_orgs
  end
end
