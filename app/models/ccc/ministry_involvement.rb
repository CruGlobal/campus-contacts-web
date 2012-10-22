class Ccc::MinistryInvolvement < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'involvementID'
  self.table_name = 'ministry_involvement'
  
end
