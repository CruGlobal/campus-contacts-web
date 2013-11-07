class Ccc::Crs2Profile < ActiveRecord::Base
  establish_connection :uscm

  self.table_name = 'crs2_profile'
  set_inheritance_column 'fake'
  belongs_to :crs2_person, class_name: 'Ccc::Crs2Person', foreign_key: :crs_person_id
  belongs_to :ministry_person, class_name: 'Ccc::Person', foreign_key: :ministry_person_id
  #belongs_to :crs2_user, class_name: 'Ccc::Crs2User', foreign_key: :user_id
  #has_many :registrants, class_name: 'Ccc::Crs2Registrant', foreign_key: :profile_id
end