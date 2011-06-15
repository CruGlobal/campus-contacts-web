class OrganizationMembership < ActiveRecord::Base
  ROLES = %w[admin leader involved contact]
  belongs_to :person
  belongs_to :organization
  
  validates_presence_of :person_id, :organization_id
  before_validation :set_primary, :on => :create
  after_destroy :set_new_primary
  
  
  def merge(other)
    OrganizationMembership.transaction do
      if other.primary? && other.updated_at && other.updated_at > updated_at
        person.organization_memberships.collect {|e| e.update_attribute(:primary, false)}
        new_primary = person.organization_memberships.detect {|e| e.organization_id == other.organization_id}
        new_primary.update_attribute(:primary, true) if new_primary
      end
      MergeAudit.create!(:mergeable => self, :merge_looser => other)
      self.validated = true if other.validated?
      self.save(:validate => false)
      other.destroy
    end
  end
  
  def leader?
    %w{admin leader}.include?(role)
  end
  
  protected
  
  def set_primary
    if person
      self.primary = person.primary_organization ? false : true
    end
    true
  end
  
  def set_new_primary
    if self.primary?
      if person && person.organization_memberships.present?
        om = person.organization_memberships.detect {|o| !o.frozen?}
        om.update_attribute(:primary, true) if om
      end
    end
    true
  end
end
