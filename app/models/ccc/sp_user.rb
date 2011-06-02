class Ccc::SpUser < ActiveRecord::Base
  belongs_to :ministry_person, :class_name => 'Ccc::MinistryPerson', :foreign_key => :person_id
  belongs_to :simplesecuritymanager_user, :class_name => 'Ccc::SimplesecuritymanagerUser', :foreign_key => :ssm_id

  def merge(other)
		if !other
			return
		elsif !self
			other.person_id = personID
			other.ssm_id = fk_ssmUserId
		else
    	type = other.type if other.type > type  #???	
    	other.destroy
  	end
		save
	end

end
