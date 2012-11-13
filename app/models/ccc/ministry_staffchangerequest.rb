class Ccc::MinistryStaffchangerequest < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'ChangeRequestID'
  self.table_name = 'ministry_staffchangerequest'
  
end
