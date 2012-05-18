class PersonTransfer < ActiveRecord::Base
  self.table_name = 'mh_person_transfers'
  attr_accessible :copy, :new_organization_id, :notified, :old_organization_id, :person_id, :transferred_by_id
  
  belongs_to :person
  belongs_to :old_organization, :class_name => 'Organization', :foreign_key => 'old_organization_id'
  belongs_to :new_organization, :class_name => 'Organization', :foreign_key => 'new_organization_id'
  belongs_to :transferred_by, :class_name => 'Person', :foreign_key => 'transferred_by_id'
  
end
