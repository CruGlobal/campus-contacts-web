class Ccc::SitrackMpd < ActiveRecord::Base
  establish_connection :uscm

	# belongs_to :person
  self.table_name = 'sitrack_mpd'


end
