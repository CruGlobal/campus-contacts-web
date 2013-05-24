class Role < ActiveRecord::Base
  has_paper_trail :on => [:destroy],
                  :meta => { organization_id: :organization_id }

  has_many :people, through: :organizational_roles
  has_many :organizational_roles, dependent: :destroy
  belongs_to :organization

  validates :i18n, uniqueness: true, allow_nil: true
  validates :name, presence: true, :if => Proc.new { |role| organization_id != 0 }
  validates :organization_id, presence: true

  scope :default, where(organization_id: 0) if Role.table_exists? # added for travis testing
	scope :mh_users, where(i18n: %w[missionhub_user admin])
  
  scope :default_roles, lambda { {
    :conditions => "i18n IN #{self.default_roles_for_field_string(self::DEFAULT_ROLES)}",
    :order => "FIELD#{self.i18n_field_plus_default_roles_for_field_string(self::DEFAULT_ROLES)}"
  }}
  scope :non_default_roles, lambda { {
    :conditions => "i18n IS NULL",
    :order => "roles.name ASC"
  }}
  scope :arrange_all, lambda {{
    order: "FIELD#{self.default_roles_for_field_string(self::DEFAULT_ROLES)}"
  }}

  def members_from_role_org(org_id, include_archive = false)
  	is_archived = include_archive ? "" : "AND archive_date IS NULL"
		organizational_roles.where("organization_id = ? AND (followup_status <> 'do_not_contact' OR followup_status IS NULL) #{is_archived}", org_id)
  end

  def self.mh_user_ids
    @mh_user_ids ||= self.mh_users.collect(&:id)
  end

  def self.admin
    @admin ||= Role.find_or_create_by_i18n_and_organization_id('admin', 0)
  end

  def self.missionhub_user
    @leader ||= Role.find_or_create_by_i18n_and_organization_id('missionhub_user', 0)
  end

  def self.contact
    @contact ||= Role.find_or_create_by_i18n_and_organization_id('contact', 0)
  end
  
  def to_s
    organization_id == 0 ? I18n.t("roles.#{i18n}") : name
  end

  def self.default_roles_for_field_string(roles)
    roles_string = "("
    roles.each do |r|
      roles_string = roles_string + "\"" + r + "\"" + ","
    end
    roles_string[roles_string.length-1] = ")"
    roles_string
  end

  def self.i18n_field_plus_default_roles_for_field_string(roles)
    r = self.default_roles_for_field_string(roles)
    r[0] = ""
    r = "(roles.i18n," + r
    r
  end

  if Role.table_exists? # added for travis testing
    ADMIN_ID = admin.id
    MH_USER_ID = missionhub_user.id
    CONTACT_ID = contact.id
  end

  DEFAULT_ROLES = ["admin", "missionhub_user", "contact"]

  ANY_SELECTED_LABEL = ["Any",1]
	ALL_SELECTED_LABEL = ["All",2]
	LABEL_SEARCH_FILTERS = [ANY_SELECTED_LABEL, ALL_SELECTED_LABEL]
end
