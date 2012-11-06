class Ccc::CrsMerchandisechoice < ActiveRecord::Base
  establish_connection :uscm

  self.table_name = 'crs_merchandisechoice'
  
end
