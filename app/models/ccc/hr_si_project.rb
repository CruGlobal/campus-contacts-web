class Ccc::HrSiProject < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'SIProjectID'
  self.table_name = 'hr_si_project'
  
end
