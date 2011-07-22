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
        if ua.registrant_type_id == cr.registrant_type_id
          ua.orphan = true
          break
        end
  		end
  		ua.profile_id = id unless ua.orphan?
			if ua.cancelled_by_id == other.user_id
				ua.concelled_by_id = user_id
			end
  		ua.save(:validate => false)			
		end

		other.crs2_person.try(:destroy)
		other.destroy
		crs2_user.merge(other.crs2_user)

		save
  end
end
