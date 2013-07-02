class Label < ActiveRecord::Base
  attr_accessible :i18n, :name, :organization_id, :created_at, :updated_at
  # added :created_at and :updated_at for migration only

  DEFAULT_LABELS = ["involved", "leader", "alumni"] # in DSC ORDER by SUPERIORITY
  CRU_ONLY_LABELS = ["engaged_disciple"]
  DEFAULT_CRU_LABELS = DEFAULT_LABELS + CRU_ONLY_LABELS

  has_many :people, through: :organizational_labels
  has_many :organizational_labels, dependent: :destroy
  belongs_to :organization

  validates :i18n, uniqueness: true, allow_nil: true
  validates :name, presence: true, :if => Proc.new { |label| organization_id != 0 }
  validates :organization_id, presence: true

  scope :default, where(organization_id: 0)

  scope :default_labels, lambda { {
    :conditions => "i18n IN #{self.default_labels_for_field_string(self::DEFAULT_LABELS)}",
    :order => "FIELD#{self.i18n_field_plus_default_labels_for_field_string(self::DEFAULT_LABELS)}"
  }}
  scope :default_cru_labels, lambda { {
    :conditions => "i18n IN #{self.default_labels_for_field_string(self::DEFAULT_CRU_LABELS)}",
    :order => "FIELD#{self.i18n_field_plus_default_labels_for_field_string(self::DEFAULT_CRU_LABELS)}"
  }}
  scope :non_default_labels, lambda { {
    :conditions => "i18n IS NULL",
    :order => "labels.name ASC"
  }}
  scope :arrange_all, lambda {{
    order: "FIELD#{self.i18n_field_plus_default_labels_for_field_string(self::DEFAULT_CRU_LABELS.reverse)} DESC, name"
  }}
  scope :arrange_all_desc, lambda {{
    order: "FIELD#{self.i18n_field_plus_default_labels_for_field_string(self::DEFAULT_CRU_LABELS.reverse)} ASC, name DESC"
  }}

  def self.involved
    @involved ||= Label.find_or_create_by_name_and_i18n_and_organization_id('Involved', 'involved', 0)
  end

  def self.engaged_disciple
    @engaged_disciple ||= Label.find_or_create_by_name_and_i18n_and_organization_id('Engaged Disciple', 'engaged_disciple', 0)
  end

  def self.leader
    @leader ||= Label.find_or_create_by_name_and_i18n_and_organization_id('Leader', 'leader', 0)
  end

  def self.alumni
    @alumni ||= Label.find_or_create_by_name_and_i18n_and_organization_id('Alumni', 'alumni', 0)
  end

  def self.sent
    @sent ||= Label.find_or_create_by_name_and_i18n_and_organization_id('100% Sent', 'sent', 0)
  end

  def self.default_labels_for_field_string(labels)
    labels_string = "("
    labels.each do |r|
      labels_string = labels_string + "\"" + r + "\"" + ","
    end
    labels_string[labels_string.length-1] = ")"
    labels_string
  end

  def self.custom_field_plus_default_labels_for_field_string(custom_field, labels)
    r = self.default_labels_for_field_string(labels)
    r[0] = ""
    r = "(#{custom_field}," + r
    r
  end

  def self.i18n_field_plus_default_labels_for_field_string(labels)
    r = self.default_labels_for_field_string(labels)
    r[0] = ""
    r = "(labels.i18n," + r
    r
  end

  def label_contacts_from_org(org)
    contact_ids = OrganizationalLabel.where(label_id: id, organization_id: org.id, removed_date: nil).uniq
    people = org.people.where(id: contact_ids.collect(&:person_id))
    people.includes(:organizational_permissions).where('organizational_permissions.organization_id' => org.id, 'organizational_permissions.archive_date' => nil)
  end

  def label_contacts_from_org_with_archived(org)
    contact_ids = OrganizationalLabel.where(label_id: id, organization_id: org.id).uniq
    people = org.people.where(id: contact_ids.collect(&:person_id))
    people.includes(:organizational_permissions).where('organizational_permissions.organization_id' => org.id)
  end

  def to_s
    name
  end

  if Label.table_exists? # added for travis testing
    LEADER_ID = leader.id
    SENT_ID = sent.id
    INVOLVED_ID = involved.id
    ALUMNI_ID = alumni.id
  end
  ANY_SELECTED_LABEL = ["Any",1]
	ALL_SELECTED_LABEL = ["All",2]
	LABEL_SEARCH_FILTERS = [ANY_SELECTED_LABEL, ALL_SELECTED_LABEL]

end
