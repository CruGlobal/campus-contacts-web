module Ccc
  module Person
    extend ActiveSupport::Concern
    
    included do
      has_many :ministry_newaddresses, :class_name => 'Ccc::MinistryNewaddress', :foreign_key => :fk_PersonID, :dependent => :destroy
			has_many :crs_registrations, :class_name => 'Ccc::CrsRegistration', :dependent => :destroy
      # has_many :crs2_profiles, :class_name => 'Ccc::Crs2Profile', :dependent => :destroy
      # has_many :ministry_missional_team_members, :class_name => 'Ccc::MinistryMissionalTeamMember', :dependent => :destroy
			has_many :rideshare_rides, :class_name => 'Ccc::RideshareRides', :foreign_key => :person_id, :dependent => :destroy
      # has_many :organization_memberships, :class_name => 'Ccc::OrganizationMembership', :dependent => :destroy
      # has_many :sn_timetables, :class_name => 'Ccc::SnTimetable', :dependent => :destroy
      has_many :sp_staff, :class_name => 'Ccc::SpStaff', :dependent => :destroy
      has_one :sp_users, :class_name => 'Ccc::SpUser', :dependent => :destroy
			has_many :sp_applications, :class_name => 'Ccc::SpApplication', :dependent => :destroy
			has_many :sp_projects, :class_name => 'Ccc::SpProject', :dependent => :destroy # ???
			has_many :sp_application_moves, :class_name => 'Ccc::SpApplicationMove', :dependent => :destroy # ???

    end
    
    module InstanceMethods
      def merge(other)
        ::Person.transaction do
          attributes.each do |k, v|
            next if k == ::Person.primary_key
            next if v == other.attributes[k]
            self[k] = case
                      when other.attributes[k].blank? then v
                      when v.blank? then other.attributes[k]
                      else
                        other.dateChanged > dateChanged ? other.attributes[k] : v
                      end
          end
          
          # Addresses
          ministry_newaddresses.each do |address|
            other_address = other.ministry_newaddresses.detect {|oa| oa.addressType == address.addressType}
            address.merge(other_address) if other_address
          end
          other.ministry_newaddresses.each {|ma| ma.update_attribute(:fk_PersonID, personID) unless ma.frozen?}
	        
 					# CRS
					other.crs_registrations.each { |ua| ua.update_attribute(:fk_PersonID, personID) }

	  			crs2_profile.merge(other.crs2_profile)

					#mpd_user.merge(other.mpd_user)

					# Panorama - these are in ccc360/app/models
					other.reviewers.each { |ua| ua.update_attribute(:person_id, personID) }
					other.reviews.each do |ua|
						ua.update_attribute(:subject_id, personID)
						ua.update_attribute(:initiator_id, personID)
					end
					other.admins.each { |ua| ua.update_attribute(:person_id, personID) }
					other.summary_forms.each { |ua| ua.update_attribute(:person_id, personID) }
					other.pr_users.each { |ua| ua.update_attribute(:ssm_id, fk_ssmUserID) }
					
					# Summer Project Tool
					other.sp_applications.each { |ua| ua.update_attribute(:person_id, personID) }

					# ???
					other.sp_projects.each do |ua|
						ua.update_attribute(:pd_id, personID)
						ua.update_attribute(:apd_id, personID)
						ua.update_attribute(:opd_id, personID)
						ua.update_attribute(:coordinator_id, personID)
					end
					
					#sp_user.merge(other.sp_user)
					other.sp_staff.each { |ua| ua.update_attribute(:person_id, personID) }
					other.sp_application_moves.each { |ua| ua.update_attribute(:moved_by_person_id, personID) }
					other.sp_applies.each { |ua| ua.update_attribute(:applicant_id, personID) }
					

					other.ministry_staff.each { |ua| ua.update_attribute(:person_id, personID) }


					other.hr_si_applications.each { |ua| ua.update_attribute(:person_id, personID) } # userID???
					other.si_users.each { |ua| ua.update_attribute(:ssm_id, fk_ssmUserID) }
					other.sitrack_mpd.each { |ua| ua.update_attribute(:person_id, personID) }
					other.sitrack_tracking.each { |ua| ua.update_attribute(:person_id, personID) }


					#other.sn_campus_involvements.each { |ua| ua.update_attribute(:person_id, personID) }
					other.sn_custom_values.each { |ua| ua.update_attribute(:person_id, personID) }
					other.sn_group_involvements.each { |ua| ua.update_attribute(:person_id, personID) }
					other.sn_ministry_involvments.each { |ua| ua.update_attribute(:person_id, personID) }
					other.sn_user_memberships.each { |ua| ua.update_attribute(:user_id, personID) }
					other.sn_training_answers.each { |ua| ua.update_attribute(:person_id, personID) }
					other.sn_imports.each { |ua| ua.update_attribute(:person_id, personID) }
					other.sn_timetables.each { |ua| ua.update_attribute(:person_id, personID) }

					other.profile_pictures.each { |ua| ua.update_attribute(:person_id, personID) }
					other.ministry_missional_team_members.each { |ua| ua.update_attribute(:person_id, personID) }
					other.rideshare_rides.each {|ua| ua.update_attribute(:person_id, personID) }



 
          MergeAudit.create!(:mergeable => self, :merge_looser => other)
          other.destroy
          save(:validate => false)
        end
      end
    end
  end
end
