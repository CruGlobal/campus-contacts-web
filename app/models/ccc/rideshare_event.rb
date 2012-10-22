class Ccc::RideshareEvent < ActiveRecord::Base
  establish_connection :uscm

  self.table_name = 'rideshare_event'
  
end
