class AddLastPushToInfobaseToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :last_push_to_infobase, :date
    add_index :interactions, :created_at
    add_column :people, :faculty, :boolean, default: false, null: false
  end
end
