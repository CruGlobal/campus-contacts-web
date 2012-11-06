class Ccc::SitrackTracking < ActiveRecord::Base
  establish_connection :uscm

	# belongs_to :person
  self.table_name = 'sitrack_tracking'

end 
