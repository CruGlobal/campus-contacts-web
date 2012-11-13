class Ccc::StaffsiteStaffsitepref < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'StaffSitePrefID'
  self.table_name = 'staffsite_staffsitepref'
  
end
