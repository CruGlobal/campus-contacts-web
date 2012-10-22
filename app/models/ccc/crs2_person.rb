class Ccc::Crs2Person < ActiveRecord::Base
  establish_connection :uscm

  self.table_name = 'crs2_person'
  has_many :crs2_profiles, class_name: 'Ccc::Crs2Profile'
end
