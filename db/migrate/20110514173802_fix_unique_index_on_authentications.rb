class FixUniqueIndexOnAuthentications < ActiveRecord::Migration
  def change
    remove_index :authentications, :name => :index_authentications_on_user_id_and_provider_and_uid
    add_index :authentications, [:provider, :uid], :unique => true
  end
end