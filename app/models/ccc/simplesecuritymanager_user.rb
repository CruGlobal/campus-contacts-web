class Ccc::SimplesecuritymanagerUser < ActiveRecord::Base
  set_primary_key :userID
  set_table_name 'simplesecuritymanager_user'
  has_many :sp_users, :class_name => 'Ccc::SpUser'
end
