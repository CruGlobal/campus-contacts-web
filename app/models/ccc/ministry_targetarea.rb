class Ccc::MinistryTargetarea < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'targetAreaID'
  self.table_name = 'ministry_targetarea'
  set_inheritance_column 'not_in_use'
  
end
