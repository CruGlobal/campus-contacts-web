class Ccc::MinistryActivityHistory < ActiveRecord::Base
  establish_connection :uscm

  self.table_name = 'ministry_activity_history'
  
end
