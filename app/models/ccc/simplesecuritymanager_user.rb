class Ccc::SimplesecuritymanagerUser < ActiveRecord::Base

  establish_connection :uscm

  self.primary_key = 'userID'
  self.table_name = 'simplesecuritymanager_user'
end