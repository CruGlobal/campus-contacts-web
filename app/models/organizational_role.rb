class OrganizationalRole < ActiveRecord::Base
  FOLLOWUP_STATUSES = ['uncontacted','attempted_contact','contacted','do_not_contact','completed']
  belongs_to :person, :touch => true
  belongs_to :role
  belongs_to :organization
  scope :leaders, where(role_id: Role.leader_ids)
  scope :involved, where(role_id: Role.involved_ids)
  scope :active, where(deleted: false)
  scope :contact, where("role_id = #{Role::CONTACT_ID}")
  # scope :not_dnc, where("followup_status <> 'do_not_contact' AND role_id = #{Role::CONTACT_ID}")
  scope :dnc, where("followup_status = 'do_not_contact' AND role_id = #{Role::CONTACT_ID}")
  scope :completed, where("followup_status = 'completed' AND role_id = #{Role::CONTACT_ID}")
  # scope :uncontacted, where("followup_status = 'uncontacted' AND role_id = #{Role::CONTACT_ID}")
  before_create :set_start_date, :set_contact_uncontacted
  before_create :notify_new_leader, :if => :role_is_leader_or_admin
  #before_destroy :check_if_only_remaining_admin_role_in_a_root_org, :check_if_admin_is_destroying_own_admin_role
  #attr_accessor :destroyer #temporary variable to remember which Person is about to destroy this role

  scope :find_non_admin_and_non_leader_roles, {
    :conditions => ["role_id != ? AND role_id != ?", Role::ADMIN_ID, Role::LEADER_ID]
  }

  #after_create :clear_person_org_cache
  #after_destroy :clear_person_org_cache

  #def clear_person_org_cache
    #person.clear_org_cache if person
  #end

  def merge(other)
    # We can have multiple roles, but if we're a contact that should be the only role
    OrganizationalRole.transaction do
      case
      when role_id == Role::CONTACT_ID && other.role_id != Role::CONTACT_ID
        MergeAudit.create!(mergeable: other, merge_looser: self)
        self.destroy
      when other.role_id == Role::CONTACT_ID && role_id != Role::CONTACT_ID
        MergeAudit.create!(mergeable: self, merge_looser: other)
        other.destroy
      when other.role_id == Role::CONTACT_ID && role_id == Role::CONTACT_ID
        # Both roles are contact, and we only need one contact role
        MergeAudit.create!(mergeable: self, merge_looser: other)
        other.destroy
      else
        # keep both roles
      end
    end
  end

  def role_is_leader_or_admin
    if (role_id == Role::LEADER_ID || role_id == Role::ADMIN_ID) && added_by_id
      true
    else
      false
    end
  end

  def create_user_for_person_if_not_existing
    if self.person.user.nil?
      return self.person.create_user!
    else
      return self.person
    end
  end

  def notify_new_leader
    self.person = create_user_for_person_if_not_existing
    if person.nil?
      raise InvalidPersonAttributesError
    else
      added_by = Person.find(added_by_id)
      token = SecureRandom.hex(12)
      person.user.remember_token = token
      person.user.remember_token_expires_at = 1.month.from_now
      person.user.save(validate: false)
      LeaderMailer.added(person, added_by, self.organization, token).deliver
    end
  end

  def archive
    update_attributes({:archive_date => Date.today})
  end

  def delete
    update_attributes({:deleted => true, :end_date => Date.today})
  end

  def unarchive
    update_attributes({:archive_date => nil})
  end

  class InvalidPersonAttributesError < StandardError

  end

  class CannotDestroyRoleError < StandardError

  end

  def check_if_only_remaining_admin_role_in_a_root_org
    raise CannotDestroyRoleError if role_id == Role::ADMIN_ID && organization.is_root_and_has_only_one_admin?
  end

  def check_if_admin_is_destroying_own_admin_role(destroyer)
    raise CannotDestroyRoleError if role_id == Role::ADMIN_ID && destroyer && person_id == destroyer.id
  end

  private

    def set_start_date
      self.start_date = Date.today
      true
    end

    def set_end_date_if_deleted
      if changed.include?('deleted') && deleted?
        update_attribute(:end_date, Date.today)
      end
    end

    def set_contact_uncontacted
      if role_id == Role::CONTACT_ID
        self.followup_status = OrganizationalRole::FOLLOWUP_STATUSES.first
      end
      true
    end
end
