class Ccc::CrsQuestion < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'questionID'
  self.table_name = 'crs_question'
  
end
