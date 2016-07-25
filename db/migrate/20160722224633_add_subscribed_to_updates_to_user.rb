class AddSubscribedToUpdatesToUser < ActiveRecord::Migration
  def change
    add_column :users, :subscribed_to_updates, :boolean
  end
end
