class Ccc::CrsChildregistration < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'childRegistrationID'
  self.table_name = 'crs_childregistration'
  
end
