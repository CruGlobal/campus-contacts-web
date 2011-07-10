class Ccc::Crs2Profile < ActiveRecord::Base
  set_table_name 'crs2_profile'
	set_inheritance_column 'fake'
  belongs_to :crs2_person, class_name: 'Ccc::Crs2Person', foreign_key: :crs_person_id
  belongs_to :ministry_person, class_name: 'Ccc::MinistryPerson', foreign_key: :ministry_person_id
  belongs_to :crs2_user, class_name: 'Ccc::Crs2User', foreign_key: :user_id
  has_many :crs2_registrants, class_name: 'Ccc::Crs2Registrant', foreign_key: :profile_id


  def merge(other)
		other.crs2_registrants.each do |ua|
  		crs2_registrants.each do |cr|
   	 		if ua.registration_type_id == cr.registration_type_id
    	  	ua.orphan = true
      		break
    		end
  		end
  		ua.profile_id = cr.profile_id unless ua.orphan?
  		ua.save(:validate => false)
		end

		crs2_user.merge(other.crs2_user)


		other.crs2_person.destroy
		other.destroy
		save
  end
end
