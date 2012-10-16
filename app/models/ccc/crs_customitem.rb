class Ccc::CrsCustomitem < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'customItemID'
  self.table_name = 'crs_customitem'
  
end
