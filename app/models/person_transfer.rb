class PersonTransfer < ActiveRecord::Base
  self.table_name = 'mh_person_transfers'
  attr_accessible :copy, :new_organization_id, :notified, :old_organization_id, :person_id
end
