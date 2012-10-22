class Ccc::MinistryMovementContact < ActiveRecord::Base
  establish_connection :uscm

  self.table_name = 'ministry_movement_contact'
  
end
