class Ccc::OldWsnSpWsnapplication < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'WsnApplicationID'
  self.table_name = 'old_wsn_sp_wsnapplication'
  
end
