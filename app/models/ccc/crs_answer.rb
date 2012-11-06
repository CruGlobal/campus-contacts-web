class Ccc::CrsAnswer < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'answerID'
  self.table_name = 'crs_answer'
  
end
