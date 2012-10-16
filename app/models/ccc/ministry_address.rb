class Ccc::MinistryAddres < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'AddressID'
  self.table_name = 'ministry_address'
  
end
