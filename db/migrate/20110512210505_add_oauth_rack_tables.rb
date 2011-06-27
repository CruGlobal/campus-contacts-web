class AddOauthRackTables < ActiveRecord::Migration
  def self.up
     # api applications?
     create_table :clients do |t|
       t.string :code
       t.string :secret
       t.string :display_name
       t.string :link
       t.string :image_url
       t.string :redirect_uri
       t.string :scope, default: ""
       t.string :notes
       t.timestamps
       t.datetime :revoked
     end

     add_index :clients, :code, unique: true
     add_index :clients, :display_name, unique: true
     add_index :clients, :link, unique: true

     create_table :auth_requests do |t|
       t.string :code
       t.string :client_id
       t.string :scope, default: ""
       t.string :redirect_uri
       t.string :state
       t.string :response_type
       t.string :grant_code
       t.string :access_token
       t.timestamps
       t.datetime :authorized_at
       t.datetime :revoked
     end

     add_index :auth_requests, :code
     add_index :auth_requests, :client_id

     create_table :access_tokens do |t|
       t.string :code
       t.string :identity
       t.string :client_id
       t.string :scope, default: ""
       t.timestamps
       t.datetime :expires_at
       t.datetime :revoked
       t.datetime :last_access
       t.datetime :prev_access
     end

     add_index :access_tokens, :code, unique: true
     add_index :access_tokens, :client_id
     add_index :access_tokens, :identity

     create_table :access_grants do |t|
       t.string :code
       t.string :identity
       t.string :client_id
       t.string :redirect_uri
       t.string :scope, default: ""
       t.timestamps
       t.datetime :granted_at
       t.datetime :expires_at
       t.string :access_token
       t.datetime :revoked
     end

     add_index :access_grants, :code, unique: true
     add_index :access_grants, :client_id

   end

   def self.down
     drop_table :clients
     drop_table :auth_requests
     drop_table :access_tokens
     drop_table :access_grants
   end

end
