class CreateApiLogs < ActiveRecord::Migration
  def change
    create_table :api_logs do |t|
      t.string :platform
      t.string :action
      t.integer :identity
      t.integer :organization_id
      t.text :error
      t.text :url
      t.string :access_token
      t.string :remote_ip

      t.timestamps
    end
  end
end
