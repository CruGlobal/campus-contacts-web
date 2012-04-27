class Ccc::MinistryDependent < ActiveRecord::Base
  self.primary_key = 'DependentID'
  self.table_name = 'ministry_dependent'
  
end
