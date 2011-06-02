class Ccc::Crs2User < ActiveRecord::Base
  set_table_name 'crs2_user'
  has_many :crs2_conferences, :class_name => 'Ccc::Crs2Conference'
  has_many :crs2_profiles, :class_name => 'Ccc::Crs2Profile'
  has_many :crs2_registrants, :class_name => 'Ccc::Crs2Registrant'
  has_many :crs2_registrations, :class_name => 'Ccc::Crs2Registration'
  has_many :crs2_transactions, :class_name => 'Ccc::Crs2Transaction'
  has_many :crs2_transactions, :class_name => 'Ccc::Crs2Transaction'
  has_many :crs2_user_roles, :class_name => 'Ccc::Crs2UserRole'


	def merge(other)
		other.crs2_conference.each { |ua| ua.update_attribute(:creator_id, id) }
		other.crs2_user_role.each { |ua| ua.update_attribute(:user_id, id) }
		other.crs2_registration.each { |ua| ua.update_attribute(:creator_id, id) } # ???
		other.crs2_transaction.each { |ua| ua.update_attribute(:verified_id, id) }
		
		other.destroy
		save
	end

end
