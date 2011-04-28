class OrganizationMembership < ActiveRecord::Base
  belongs_to :person
  belongs_to :organization
  
  validates_presence_of :person_id, :organization_id
  before_validation :set_primary, :on => :create
  after_destroy :set_new_primary
  
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
