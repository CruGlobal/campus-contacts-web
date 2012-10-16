class Ccc::StaffsiteStaffsiteprofile < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'StaffSiteProfileID'
  self.table_name = 'staffsite_staffsiteprofile'
  
end
