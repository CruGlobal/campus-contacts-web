class FixUniqueIndexOnAuthentications < ActiveRecord::Migration
  def change
    add_index :authentications, [:provider, :uid], unique: true
  end
end