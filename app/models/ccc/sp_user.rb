class Ccc::SpUser < ActiveRecord::Base
  belongs_to :ministry_person, class_name: 'Person', foreign_key: :person_id
  belongs_to :simplesecuritymanager_user, class_name: 'Ccc::SimplesecuritymanagerUser', foreign_key: :ssm_id

  def merge(other)
		roles = %w{SPNationalCoordinator SpRegionalCoordinator SpDirector SpProjectStaff SpGeneralStaff}
		if other.type != nil and roles.index_of(other.type) < roles.index_of(type)
   		self.type = other.type
		end	
   	other.destroy
		save
  end

end
