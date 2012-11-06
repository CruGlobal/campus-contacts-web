class Ccc::MinistryActivity < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'ActivityID'
  self.table_name = 'ministry_activity'
  
end
