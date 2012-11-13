class Ccc::CrsConference < ActiveRecord::Base
  establish_connection :uscm

  self.primary_key = 'conferenceID'
  self.table_name = 'crs_conference'
  
end
