class Ccc::MinistryTargetarea < ActiveRecord::Base
  set_primary_key :targetAreaID
  set_table_name 'ministry_targetarea'
  set_inheritance_column 'not_in_use'
  
end
