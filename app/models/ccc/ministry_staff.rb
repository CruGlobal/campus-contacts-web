class Ccc::MinistryStaff < ActiveRecord::Base
  establish_connection :uscm

	# belongs_to :person
  self.table_name = 'ministry_staff'

end
