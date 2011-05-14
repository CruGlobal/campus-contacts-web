class OrganizationMembership < ActiveRecord::Base
  belongs_to :person
  belongs_to :organization
  
  validates_presence_of :person_id, :organization_id
  before_validation :set_primary, :on => :create
  after_destroy :set_new_primary
  
  
  def merge(other)
    OrganizationMembership.transaction do
      if other.primary? && other.updated_at > updated_at
        person.organization_membership.collect {|e| e.update_attribute(:primary, false)}
        new_primary = person.organization_membership.detect {|e| e.organization_id == other.organization_id}
        new_primary.update_attribute(:primary, true) if new_primary
      end
      self.validated = true if other.validated?
      self.save(:validate => false)
      other.destroy
    end
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
      if person && person.organizations.present?
        person.organizations.first.update_attribute(:primary, true)
      end
    end
    true
  end
end
