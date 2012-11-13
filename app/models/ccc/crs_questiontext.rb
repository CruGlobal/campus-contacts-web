class Ccc::CrsQuestiontext < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'questionTextID'
  self.table_name = 'crs_questiontext'
  
end
