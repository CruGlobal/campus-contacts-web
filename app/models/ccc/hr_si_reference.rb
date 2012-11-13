class Ccc::HrSiReference < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'referenceID'
  self.table_name = 'hr_si_reference'
  
end
