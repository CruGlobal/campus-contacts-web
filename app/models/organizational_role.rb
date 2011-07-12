class OrganizationalRole < ActiveRecord::Base
  belongs_to :person
  belongs_to :role
  belongs_to :organization
  scope :leaders, where(role_id: Role.leader_ids)
  scope :active, where(deleted: false)
  scope :not_dnc, where("followup_status <> 'do_not_contact'")
  scope :dnc, where("followup_status = 'do_not_contact'")
  before_create :set_start_date, :set_contact_uncontacted
  after_save :set_end_date_if_deleted
  
  
  def merge(other)
    # We can have multiple roles, but if we're a contact that should be the only role
    OrganizationalRole.transaction do
      case
      when role_id == Role.contact.id && other.role_id != Role.contact.id
        MergeAudit.create!(mergeable: other, merge_looser: self)
        self.destroy
      when other.role_id == Role.contact.id && role_id != Role.contact.id
        MergeAudit.create!(mergeable: self, merge_looser: other)
        other.destroy
      when other.role_id == Role.contact.id && role_id == Role.contact.id
        # Both roles are contact, and we only need one contact role
        MergeAudit.create!(mergeable: self, merge_looser: other)
        other.destroy
      else
        # keep both roles
      end
    end
  end
  private
    def set_start_date
      self.start_date = Date.today
      true
    end
    
    def set_end_date_if_deleted
      if changed.include?('deleted') && deleted?
        udpate_attribute(:end_date, Date.today)
      end
    end
    
    def set_contact_uncontacted
      if role_id == Role.contact.id
        self.followup_status = OrganizationMembership::FOLLOWUP_STATUSES.first
      end
      true
    end
end
