module Ccc
	module SimplesecuritymanagerUser
		extend ActiveSupport::Concern

	included do
  	set_primary_key :userID
  	set_table_name 'simplesecuritymanager_user'
  	has_one :sp_user, class_name: 'Ccc::SpUser'
  	has_one :mpd_user, class_name: 'Ccc::MpdUser', dependent: :destroy
		has_one :si_user, class_name: 'Ccc::SiUser', foreign_key: 'ssm_id'
    has_one :pr_user, class_name: 'Ccc::PrUser', dependent: :destroy, foreign_key: 'ssm_id'
		has_many :sn_user_memberships, class_name: 'Ccc::SnUserMembership'
	end  

		module InstanceMethods
  		def merge(other)
    		if other.mpd_user and mpd_user
      		mpd_user.merge(other.mpd_user)
    		elsif other.mpd_user
     		 other.mpd_user.user_id = userID
    		end
  
				if other.pr_user and pr_user
					other.pr_user.destroy				
				elsif other.pr_user
					other.pr_user.ssm_id = userID
				end
				
				if other.si_user and si_user
					other.si_user.destroy				
				elsif other.si_user
					SiUser.where(["ssm_id = ? or created_by_id = ?", other.userID, other.userID]).each do |ua|
						ua.update_attribute(:ssm_id, personID) if ua.ssm_id == other.userID
						ua.update_attribute(:created_by_id, personID) if ua.created_by_id == other.userID
					end
				end
				
				other.sn_user_memberships.each { |ua| ua.update_attribute(:user_id, id) }

			end
		end
  end
end
