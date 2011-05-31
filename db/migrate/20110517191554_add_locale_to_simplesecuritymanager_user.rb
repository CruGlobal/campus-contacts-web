class AddLocaleToSimplesecuritymanagerUser < ActiveRecord::Migration
  def change
    add_column :simplesecuritymanager_user, :locale, :string
  end
end
