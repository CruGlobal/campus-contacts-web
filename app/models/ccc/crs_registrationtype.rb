class Ccc::CrsRegistrationtype < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'registrationTypeID'
  self.table_name = 'crs_registrationtype'
  
end
