class Ccc::RideshareRide < ActiveRecord::Base
  establish_connection :uscm

	#belongs_to :person
  self.table_name = 'rideshare_ride'

end
