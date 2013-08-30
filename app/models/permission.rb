class Permission < ActiveRecord::Base
  has_paper_trail :on => [:destroy],
                  :meta => { organization_id: :organization_id }

  has_many :people, through: :organizational_permissions
  has_many :organizational_permissions, dependent: :destroy

  validates :i18n, uniqueness: true, allow_nil: true
  validates :name, presence: true

  scope :default, where(i18n: ['admin','user','no_permissions']) if Permission.table_exists? # added for travis testing
	scope :users, where(i18n: %w[user admin])

  scope :default_permissions, lambda { {
    :conditions => "i18n IN #{self.default_permissions_for_field_string(self::DEFAULT_PERMISSIONS)}",
    :order => "FIELD#{self.i18n_field_plus_default_permissions_for_field_string(self::DEFAULT_PERMISSIONS)}"
  }}
  scope :non_default_permissions, lambda { {
    :conditions => "i18n IS NULL",
    :order => "permissions.name ASC"
  }}
  scope :arrange_all, lambda {{
    order: "#{self.order_default_permissions}"
  }}

  def self.order_default_permissions
    str = "CASE "
    self::DEFAULT_PERMISSIONS.each_with_index do |p, i|
      str = str + "WHEN permissions.i18n = '#{p}' THEN #{i} "
    end
    str = str + "ELSE permissions.id END"
  end

  def members_from_permission_org(org_id, include_archive = false)
  	is_archived = include_archive ? "" : "AND archive_date IS NULL"
		organizational_permissions.where("deleted_at IS NULL AND organization_id = ? AND (followup_status <> 'do_not_contact' OR followup_status IS NULL) #{is_archived}", org_id)
  end

  def self.user_ids
    @user_ids ||= self.users.collect(&:id)
  end

  def self.admin
    @admin ||= Permission.find_or_create_by_name_and_i18n('Admin','admin')
  end

  def self.user
    @user ||= Permission.find_or_create_by_name_and_i18n('User','user')
  end

  def self.no_permissions
    @no_permissions ||= Permission.find_or_create_by_name_and_i18n('No Permissions','no_permissions')
  end

  def to_s
    ['admin','user','no_permissions'].include?(i18n) ? I18n.t("permissions.#{i18n}") : name
  end

  def self.default_permissions_for_field_string(permissions)
    permissions_string = "("
    permissions.each do |r|
      permissions_string = permissions_string + "\"" + r + "\"" + ","
    end
    permissions_string[permissions_string.length-1] = ")"
    permissions_string
  end

  def self.i18n_field_plus_default_permissions_for_field_string(permissions)
    r = self.default_permissions_for_field_string(permissions)
    r[0] = ""
    r = "(permissions.i18n," + r
    r
  end

  def permission_contacts_from_org(org)
    people_ids = OrganizationalPermission.where(permission_id: id, organization_id: org.id).collect(&:person_id).uniq
    people = org.all_people.where(id: people_ids)
  end

  def permission_contacts_from_org_with_archived(org)
    people_ids = OrganizationalPermission.where(permission_id: id, organization_id: org.id).collect(&:person_id).uniq
    org.all_people_with_archived.where(id: people_ids)
  end

  def to_s
    name
  end

  if Permission.table_exists? # added for travis testing
    ADMIN_ID = admin.id
    USER_ID = user.id
    NO_PERMISSIONS_ID = no_permissions.id
  end

  DEFAULT_PERMISSIONS = ["admin", "user", "no_permissions"]

  ANY_SELECTED_LABEL = ["Any",1]
	ALL_SELECTED_LABEL = ["All",2]
	LABEL_SEARCH_FILTERS = [ANY_SELECTED_LABEL, ALL_SELECTED_LABEL]

  def self.is_set_to_user_or_admin?(permission_id)
    (is_set_to_user?(permission_id) || is_set_to_admin?(permission_id))
  end

  def self.is_set_to_user?(permission_id)
    permission_id == USER_ID
  end

  def self.is_set_to_admin?(permission_id)
    permission_id == ADMIN_ID
  end

  def apiv1_i18n
    case self.i18n
      when 'admin'
        'admin'
      when 'user'
        'leader'
      else
        'contact'
    end
  end

  def apiv1_name
    case self.i18n
      when 'admin'
        'Admin'
      when 'user'
        'Leader'
      else
        'Contact'
    end
  end
end
