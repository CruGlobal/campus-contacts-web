class NewPerson < ActiveRecord::Base
  self.table_name = 'mh_new_people'
  attr_accessible :notified, :organization_id, :person_id
  
  belongs_to :person
end
