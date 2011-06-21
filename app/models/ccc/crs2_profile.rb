class Ccc::Crs2Profile < ActiveRecord::Base
  set_table_name 'crs2_profile'
  belongs_to :crs2_person, :class_name => 'Ccc::Crs2Person', :foreign_key => :crs_person_id
  belongs_to :ministry_person, :class_name => 'Ccc::MinistryPerson', :foreign_key => :ministry_person_id
  belongs_to :crs2_user, :class_name => 'Ccc::Crs2User', :foreign_key => :user_id
  has_many :crs2_registrants, :class_name => 'Ccc::Crs2Registrant'


  def merge(other)

   	other.crs2_registrants.each { |ua| ua.update_attribute(:profile_id, id) }
		crs2_user.merge(other.crs2_user)


		other.crs2_person.destroy
		other.destroy
		save
  end
end
