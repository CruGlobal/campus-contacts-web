require 'permission'
class OrganizationalPermission < ActiveRecord::Base
  has_paper_trail :meta => { organization_id: :organization_id,
                             person_id: :person_id }

  FOLLOWUP_STATUSES = ['uncontacted','attempted_contact','contacted','do_not_contact','completed']
  belongs_to :person, :touch => true
  belongs_to :permission
  belongs_to :organization

  scope :active, where("organizational_permissions.archive_date is NULL AND organizational_permissions.deleted_at is NULL")
  scope :contact, where("permission_id = #{Permission::NO_PERMISSIONS_ID} AND organizational_permissions.deleted_at is NULL")
  # scope :not_dnc, where("followup_status <> 'do_not_contact' AND permission_id = #{Permission::NO_PERMISSIONS_ID}")
  scope :dnc, where("followup_status = 'do_not_contact' AND permission_id = #{Permission::NO_PERMISSIONS_ID} AND organizational_permissions.deleted_at is NULL")
  scope :completed, where("followup_status = 'completed' AND permission_id = #{Permission::NO_PERMISSIONS_ID} AND organizational_permissions.deleted_at is NULL")
  # scope :uncontacted, where("followup_status = 'uncontacted' AND permission_id = #{Permission::NO_PERMISSIONS_ID}")
  before_create :set_start_date, :set_contact_uncontacted
  before_save :notify_new_leader, :if => :permission_is_leader_or_admin
  #before_destroy :check_if_only_remaining_admin_permission_in_a_root_org, :check_if_admin_is_destroying_own_admin_permission
  #attr_accessor :destroyer #temporary variable to remember which Person is about to destroy this permission

  scope :find_non_admin_and_non_leader_permissions, {
    :conditions => ["permission_id != ? AND permission_id != ?", Permission::ADMIN_ID, Permission::USER_ID]
  }

  scope :find_admin_or_leader, {
    :conditions => ["permission_id = ? OR permission_id = ?", Permission::ADMIN_ID, Permission::USER_ID]
  }

  #after_create :clear_person_org_cache
  #after_destroy :clear_person_org_cache

  #def clear_person_org_cache
    #person.clear_org_cache if person
  #end

  def merge(other)
    # We can have multiple permissions, but if we're a contact that should be the only permission
    OrganizationalPermission.transaction do
      case
      when permission_id == other.permission_id
        # Both permissions are the same, and we only need one contact permission
        MergeAudit.create!(mergeable: self, merge_looser: other)
        other.destroy
      when permission_id == Permission::ADMIN_ID && other.permission_id != Permission::ADMIN_ID
        MergeAudit.create!(mergeable: self, merge_looser: other)
        other.destroy
      when permission_id != Permission::ADMIN_ID && other.permission_id == Permission::ADMIN_ID
        MergeAudit.create!(mergeable: other, merge_looser: self)
        self.destroy
      when permission_id == Permission::USER_ID && other.permission_id != Permission::USER_ID
        MergeAudit.create!(mergeable: self, merge_looser: other)
        other.destroy
      when permission_id != Permission::USER_ID && other.permission_id == Permission::USER_ID
        MergeAudit.create!(mergeable: other, merge_looser: self)
        self.destroy
      end
    end
  end

  def permission_is_leader_or_admin
    leader_permission = permission_id == Permission::USER_ID || permission_id == Permission::ADMIN_ID
    is_new = self.new_record?
    is_updated = (self.permission_id_changed? || self.archive_date_changed? || self.deleted_at_changed?)
    is_active = self.archive_date.nil? && self.deleted_at.nil?
    new_or_updated = is_new || (is_updated && is_active)
    has_added_by_id = added_by_id.present?
    return leader_permission && has_added_by_id && new_or_updated
  end

  def create_user_for_person_if_not_existing
    return self.person.create_user! if self.person && self.person.user.nil?
    return self.person
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

  def delete
    update_attributes({deleted_at: Date.today})
  end

  def archive
    update_attributes({:archive_date => Date.today})
  end

  def unarchive
    update_attributes({:archive_date => nil})
  end

  class InvalidPersonAttributesError < StandardError

  end

  class CannotDestroyPermissionError < StandardError

  end

  def check_if_only_remaining_admin_permission_in_a_root_org
    raise CannotDestroyPermissionError if permission_id == Permission::ADMIN_ID && organization.is_root_and_has_only_one_admin?
  end

  def check_if_admin_is_destroying_own_admin_permission(destroyer)
    raise CannotDestroyPermissionError if permission_id == Permission::ADMIN_ID && destroyer && person_id == destroyer.id
  end

  private

    def set_start_date
      self.start_date = Date.today
      true
    end

    def set_contact_uncontacted
      if permission_id == Permission::NO_PERMISSIONS_ID
        self.followup_status = OrganizationalPermission::FOLLOWUP_STATUSES.first
      end
      true
    end
end
