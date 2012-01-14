class Ccc::Crs2Profile < ActiveRecord::Base
  set_table_name 'crs2_profile'
	set_inheritance_column 'fake'
  belongs_to :crs2_person, class_name: 'Ccc::Crs2Person', foreign_key: :crs_person_id
  belongs_to :ministry_person, class_name: 'Person', foreign_key: :ministry_person_id
  belongs_to :crs2_user, class_name: 'Ccc::Crs2User', foreign_key: :user_id
  has_many :crs2_registrants, class_name: 'Ccc::Crs2Registrant', foreign_key: :profile_id


  def merge(other)
		other.crs2_registrants.each do |other_registrant|
  		crs2_registrants.each do |registrant|
        if other_registrant.registrant_type_id == registrant.registrant_type_id
          other_registrant.update_column(:orphan, true)
          other_registrant.update_column(:profile_id, nil)
          break
        end
  		end
  		other_registrant.profile_id = id unless other_registrant.orphan?
			if other_registrant.cancelled_by_id == other.user_id
				other_registrant.cancelled_by_id = user_id
			end
  		other_registrant.save(:validate => false)			
		end

		other.crs2_person.try(:destroy)
		if crs2_user && other.crs2_user
  		crs2_user.merge(other.crs2_user)
		elsif other.crs2_user
		  self.user_id = other.user_id
	  end
    
    other.reload
		other.destroy
    other.user.destroy if other.user
		save
  end
end
