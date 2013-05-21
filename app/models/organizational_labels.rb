class OrganizationalLabels < ActiveRecord::Base
  attr_accessible :added_by_id, :label_id, :organization_id, :person_id, :removed_date, :start_date
end
