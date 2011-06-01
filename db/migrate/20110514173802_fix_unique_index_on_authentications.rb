class FixUniqueIndexOnAuthentications < ActiveRecord::Migration
  def change
    remove_index :authentications, :name => :user_id_provider_uid
    add_index :authentications, [:provider, :uid], :unique => true
  end
end