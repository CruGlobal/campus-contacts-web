class ContactAssignment < ActiveRecord::Base
  attr_accessible :assigned_to_id, :person_id, :notified, :assigned_by_id, :organization_id

  has_paper_trail :on => [:destroy],
                  :meta => { organization_id: :organization_id }

  belongs_to :assigned_to, class_name: "Person", foreign_key: "assigned_to_id"
  belongs_to :assigned_by, class_name: "Person", foreign_key: "assigned_by_id"
  belongs_to :person
  belongs_to :organization
  scope :for_org,
    ->(org_id){where(organization_id: org_id)}

  def deleted_at
    version = versions.last
    if version
      version.created_at
    end
  end

  def self.assignment_counts_for(leader_ids, org_id, include_archived = false)
    joins = where(assigned_to_id: leader_ids, organization_id: org_id)
        .joins('INNER JOIN organizational_permissions ON organizational_permissions.person_id = contact_assignments.person_id '+
                  'AND organizational_permissions.organization_id = contact_assignments.organization_id '+
                  'AND organizational_permissions.deleted_at is null')
        .joins('INNER JOIN people on people.id = contact_assignments.person_id')
    joins = joins.where(organizational_permissions: { archive_date: nil }).references('organizational_permissions') unless include_archived
    joins.group(:assigned_to_id).count('distinct contact_assignments.person_id')
  end
end
