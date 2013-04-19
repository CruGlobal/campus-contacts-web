class CreateNewUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password
      t.datetime :lastLogin
      t.datetime :createdOn
      t.string :remember_token
      t.string :locale
      t.datetime :remember_token_expires_at
      t.integer :developer
    end
  end
end
