class Ccc::Crs2Profile < ActiveRecord::Base
  set_table_name 'crs2_profile'
  belongs_to :crs2_person, :class_name => 'Ccc::Crs2Person', :foreign_key => :crs_person_id
  belongs_to :ministry_person, :class_name => 'Ccc::MinistryPerson', :foreign_key => :ministry_person_id
  belongs_to :crs2_user, :class_name => 'Ccc::Crs2User', :foreign_key => :user_id
  has_many :crs2_registrants, :class_name => 'Ccc::Crs2Registrant'
end
