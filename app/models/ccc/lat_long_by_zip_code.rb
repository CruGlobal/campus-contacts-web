class Ccc::LatLongByZipCode < ActiveRecord::Base
  establish_connection :uscm

  self.table_name = 'lat_long_by_zip_code'
  
end
