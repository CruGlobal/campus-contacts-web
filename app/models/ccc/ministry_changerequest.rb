class Ccc::MinistryChangerequest < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'ChangeRequestID'
  self.table_name = 'ministry_changerequest'
  
end
