require 'permission'
class OrganizationalPermission < ActiveRecord::Base
  has_paper_trail :meta => { organization_id: :organization_id,
                             person_id: :person_id }

  FOLLOWUP_STATUSES = ['uncontacted','attempted_contact','contacted','do_not_contact','completed']
  attr_accessible :person_id, :permission_id, :start_date, :organization_id, :cru_status_id, :followup_status, :added_by_id,
    :archive_date, :deleted_at

  before_create :set_start_date, :set_contact_uncontacted
  before_save :notify_new_leader, :if => :permission_is_leader_or_admin

  belongs_to :cru_status
  belongs_to :person, :touch => true
  belongs_to :permission
  belongs_to :organization

  scope :active,
    ->{where("organizational_permissions.archive_date is NULL AND organizational_permissions.deleted_at is NULL")}
  scope :contact,
    ->{where("permission_id = #{Permission::NO_PERMISSIONS_ID} AND organizational_permissions.deleted_at is NULL")}
  scope :dnc,
    ->{where("followup_status = 'do_not_contact' AND permission_id = #{Permission::NO_PERMISSIONS_ID} AND organizational_permissions.deleted_at is NULL")}
  scope :completed,
    ->{where("followup_status = 'completed' AND permission_id = #{Permission::NO_PERMISSIONS_ID} AND organizational_permissions.deleted_at is NULL")}
  scope :find_non_admin_and_non_leader_permissions,
    ->{where("permission_id != ? AND permission_id != ?", Permission::ADMIN_ID, Permission::USER_ID)}
  scope :find_admin_or_leader,
    ->{where("permission_id = ? OR permission_id = ?", Permission::ADMIN_ID, Permission::USER_ID)}

  validate do |value|
    # if person have email
    if [Permission.admin.id, Permission.user.id].include?(value.permission_id)
      if person = Person.find(value.person_id)
        unless person.email.present?
          errors.add(:base, "This person does not have an email address")
        end
      end
    end
  end

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

  def self.get_permission_hash(org, people)
    permission_hash = Hash.new
    self.active.where(organization_id: org.id, person_id: people.collect(&:id)).each do |op|
      permission_hash[op.id] = op if op.permission_id == Permission::NO_PERMISSIONS_ID
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
    person = create_user_for_person_if_not_existing
    if person.blank? || person.user.blank?
      raise InvalidPersonAttributesError
    else
      token = SecureRandom.hex(12)
      person.user.remember_token = token
      person.user.remember_token_expires_at = 1.month.from_now
      person.user.save(validate: false)
      LeaderMailer.delay.added(person, added_by_id, self.organization, token, permission.name)
    end
  end

  def delete
    update_attributes(deleted_at: Date.today)
  end

  def archive
    update_attributes(archive_date: Date.today)
  end

  def unarchive
    update_attributes(archive_date: nil)
  end

  def self.is_archived?(organization)
    self.where('organizational_permissions.organization_id' => organization.id).blank?
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
