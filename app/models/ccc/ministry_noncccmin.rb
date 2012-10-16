class Ccc::MinistryNoncccmin < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'NonCccMinID'
  self.table_name = 'ministry_noncccmin'
  
end
