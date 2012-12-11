class ContactAssignment < ActiveRecord::Base
  has_paper_trail :on => [:destroy],
                  :meta => { organization_id: :organization_id }

  belongs_to :assigned_to, class_name: "Person", foreign_key: "assigned_to_id"
  belongs_to :person
  belongs_to :organization
  scope :for_org, lambda {|org_id| where(organization_id: org_id)}

  def deleted_at
    version = versions.last
    if version
      version.created_at
    end
  end
end
