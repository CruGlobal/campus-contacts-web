class NewPerson < ActiveRecord::Base
  attr_accessible :notified, :organization_id, :person_id
  
  belongs_to :person
  belongs_to :organization
end
