class Ccc::SimplesecuritymanagerUser < ActiveRecord::Base
  set_primary_key :userID
  set_table_name 'simplesecuritymanager_user'
  has_one :sp_user, class_name: 'Ccc::SpUser'
  has_one :mpd_user, class_name: 'Ccc::MpdUser', dependent: :destroy
  
  def merge(other)
    if other.mpd_user and mpd_user
      mpd_user.merge(other.mpd_user)
    elsif other.mpd_user
      other.mpd_user.user_id = fk_ssmUserID
    end
  
		if other.pr_user and pr_user
			other.pr_user.destroy				
		elsif other.pr_user
			other.pr_user.ssm_id = fk_ssmUserID
		end
  end
end
