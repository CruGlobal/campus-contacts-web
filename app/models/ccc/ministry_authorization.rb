class Ccc::MinistryAuthorization < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'AuthorizationID'
  self.table_name = 'ministry_authorization'
  
end
