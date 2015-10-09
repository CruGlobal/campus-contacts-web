class Label < ActiveRecord::Base
  NO_SELECTED_LABEL = ['No label', 1]
  ANY_SELECTED_LABEL = ['Any', 2]
  ALL_SELECTED_LABEL = ['All', 3]
  LABEL_SEARCH_FILTERS = [NO_SELECTED_LABEL, ANY_SELECTED_LABEL, ALL_SELECTED_LABEL]

  attr_accessible :i18n, :name, :organization_id, :created_at, :updated_at
  # added :created_at and :updated_at for migration only

  DEFAULT_LABELS = %w(involved leader) # in DSC ORDER by SUPERIORITY
  DEFAULT_CRU_LABELS = %w(involved engaged_disciple leader)
  DEFAULT_BRIDGE_LABELS = DEFAULT_CRU_LABELS + ['seeker']
  DEFAULT_POWER_TO_CHANGE_LABELS = %w(knows_and_trusts_christian became_curious became_open_to_change
                                      seeking_god made_decision growing_disciple ministering_disciple multiplying_disciple)

  has_many :people, through: :organizational_labels
  has_many :organizational_labels, dependent: :destroy
  belongs_to :organization

  validates :i18n, uniqueness: true, allow_nil: true
  validates :name, presence: true, if: proc { |_label| organization_id != 0 }
  validates :organization_id, presence: true

  scope :default, -> { where(organization_id: 0) }
  scope :default_labels,
        lambda {
          where("i18n IN #{default_labels_for_field_string(self::DEFAULT_LABELS)}")
            .order("FIELD#{i18n_field_plus_default_labels_for_field_string(self::DEFAULT_LABELS)}")
        }
  scope :default_cru_labels,
        lambda {
          where("i18n IN #{default_labels_for_field_string(self::DEFAULT_CRU_LABELS)}")
            .order("FIELD#{i18n_field_plus_default_labels_for_field_string(self::DEFAULT_CRU_LABELS)}")
        }
  scope :default_bridge_labels,
        lambda {
          where("i18n IN #{default_labels_for_field_string(self::DEFAULT_BRIDGE_LABELS)}")
            .order("FIELD#{i18n_field_plus_default_labels_for_field_string(self::DEFAULT_BRIDGE_LABELS)}")
        }
  scope :default_power_to_change_labels,
        lambda {
          where("i18n IN #{default_labels_for_field_string(self::DEFAULT_POWER_TO_CHANGE_LABELS)}")
            .order("FIELD#{i18n_field_plus_default_labels_for_field_string(self::DEFAULT_POWER_TO_CHANGE_LABELS)}")
        }
  scope :non_default_labels,
        lambda {
          where('i18n IS NULL')
            .order('labels.name ASC')
        }
  scope :arrange_all,
        lambda {
          order("FIELD#{i18n_field_plus_default_labels_for_field_string(self::DEFAULT_CRU_LABELS.reverse)} DESC, name")
        }
  scope :arrange_all_desc,
        lambda {
          order("FIELD#{i18n_field_plus_default_labels_for_field_string(self::DEFAULT_CRU_LABELS.reverse)} ASC, name DESC")
        }

  def self.involved
    @involved ||= Label.where(name: 'Involved', i18n: 'involved', organization_id: 0).first_or_create
  end

  def self.engaged_disciple
    @engaged_disciple ||= Label.where(name: 'Engaged Disciple', i18n: 'engaged_disciple', organization_id: 0).first_or_create
  end

  def self.leader
    @leader ||= Label.where(name: 'Leader', i18n: 'leader', organization_id: 0).first_or_create
  end

  def self.seeker
    @seeker ||= Label.where(name: 'Seeker', i18n: 'seeker', organization_id: 0).first_or_create
  end

  def self.default_labels_for_field_string(labels)
    labels_string = '('
    labels.each do |r|
      labels_string = labels_string + "\"" + r + "\"" + ','
    end
    labels_string[labels_string.length - 1] = ')'
    labels_string
  end

  def self.custom_field_plus_default_labels_for_field_string(custom_field, labels)
    r = default_labels_for_field_string(labels)
    r[0] = ''
    r = "(#{custom_field}," + r
    r
  end

  def self.i18n_field_plus_default_labels_for_field_string(labels)
    r = default_labels_for_field_string(labels)
    r[0] = ''
    r = '(labels.i18n,' + r
    r
  end

  def label_contacts_from_org(org)
    people_ids = OrganizationalLabel.where(label_id: id, organization_id: org.id, removed_date: nil).collect(&:person_id).uniq
    people = org.all_people.where(id: people_ids)
  end

  def count_label_contacts_from_orgs(org_ids, date)
    people_ids = OrganizationalLabel.where(label_id: id, organization_id: org_ids)
                 .where('start_date <= ?', date).where('removed_date is null or removed_date >= ?', date).collect(&:person_id).uniq
    result = 0
    org_ids.each do |org_id|
      org = Organization.find(org_id)
      result += org.all_people_with_archived_by_date(date).where(id: people_ids).count
    end
    result
  end

  def label_contacts_from_org_with_archived(org)
    people_ids = OrganizationalLabel.where(label_id: id, organization_id: org.id, removed_date: nil).collect(&:person_id).uniq
    people = org.all_people_with_archived.where(id: people_ids)
  end

  def to_s
    name
  end

  if Label.table_exists? # added for travis testing
    LEADER_ID = leader.id
    INVOLVED_ID = involved.id
    ENGAGED_DISCIPLE = engaged_disciple.id
    SEEKER_ID = seeker.id
  end
end
