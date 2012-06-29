class AddSettingsToSimplesecuritymanagerUser < ActiveRecord::Migration
  def change
    add_column :simplesecuritymanager_user, :settings, :text
  end
end
