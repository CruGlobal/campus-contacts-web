class Ccc::MinistryRegionalstat < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'RegionalStatID'
  self.table_name = 'ministry_regionalstat'
  
end
