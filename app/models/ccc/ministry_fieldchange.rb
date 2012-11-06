class Ccc::MinistryFieldchange < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'FieldChangeID'
  self.table_name = 'ministry_fieldchange'
  
end
