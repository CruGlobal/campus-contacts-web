class CreateInfobaseUsers < ActiveRecord::Migration
  def change
    create_table :infobase_users do |t|
      t.integer  "user_id"
      t.string   "type",       :default => "InfobaseAdminUser"
      t.integer  "created_by"
      t.timestamps
    end
  end
end
