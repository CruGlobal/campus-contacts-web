class Ccc::CrsMerchandise < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'merchandiseID'
  self.table_name = 'crs_merchandise'
  
end
