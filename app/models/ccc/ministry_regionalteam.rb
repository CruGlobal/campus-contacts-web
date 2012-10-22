class Ccc::MinistryRegionalteam < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'teamID'
  self.table_name = 'ministry_regionalteam'
  
end
