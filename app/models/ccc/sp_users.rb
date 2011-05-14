class Ccc::SpUser < ActiveRecord::Base
  belongs_to :ministry_person, :class_name => 'Ccc::MinistryPerson', :foreign_key => :person_id
  belongs_to :simplesecuritymanager_user, :class_name => 'Ccc::SimplesecuritymanagerUser', :foreign_key => :ssm_id
end
