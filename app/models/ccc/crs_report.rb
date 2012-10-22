class Ccc::CrsReport < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'reportID'
  self.table_name = 'crs_report'
  
end
