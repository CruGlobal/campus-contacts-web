class InteractionType < ActiveRecord::Base
  COMMENT = 1
  SPIRITUAL_CONVERSATION = 2
  PERSONAL_EVANGELISM = 3
  PERSONAL_DECISION = 4
  HOLY_SPIRIT_PRESENTATION = 5
  GRADUATING_ON_MISSION = 6
  DISCIPLESHIP = 9

  CORE_INTERACTIONS = [SPIRITUAL_CONVERSATION,
                       PERSONAL_EVANGELISM,
                       PERSONAL_DECISION,
                       HOLY_SPIRIT_PRESENTATION,
                       DISCIPLESHIP].freeze

  attr_accessible :i18n, :icon, :name, :organization_id

  has_many :interactions

  scope :exclude_comment, -> { where("i18n <> 'comment'") }

  def title
    if i18n.present?
      I18n.t("application.interaction_types.#{i18n}")
    else
      name
    end
  end

  def self.old_rejoicable_ids
    InteractionType.where(i18n: %w(spiritual_conversation gospel_presentation prayed_to_receive_christ), organization_id: 0).collect(&:id)
  end

  def self.comment
    InteractionType.where(i18n: 'comment', organization_id: 0).first_or_create
  end

  def self.graduating_on_mission
    InteractionType.where(i18n: 'graduating_on_mission', organization_id: 0).first_or_create
  end

  def self.get_interaction_types_hash(org_id)
    interaction_types = InteractionType.where('organization_id = 0 OR organization_id = ?', org_id).order('id')
    interaction_types.collect(&:to_hash)
  end

  def interaction_receivers_from_org(org)
    people_with_interaction = Interaction.where(interaction_type_id: id, organization_id: org.id, deleted_at: nil).collect(&:receiver_id)
    contacts_with_permission = org.all_people.includes(:organizational_permissions).where('organizational_permissions.organization_id' => org.id, 'organizational_permissions.archive_date' => nil, 'organizational_permissions.deleted_at' => nil, 'organizational_permissions.person_id' => people_with_interaction)
    contacts_with_permission
  end

  def interaction_receivers_from_org_with_archived(org)
    people_with_interaction = Interaction.where(interaction_type_id: id, organization_id: org.id, deleted_at: nil).collect(&:receiver_id)
    contacts_with_permission = org.all_people_with_archived.includes(:organizational_permissions).where('organizational_permissions.organization_id' => org.id, 'organizational_permissions.person_id' => people_with_interaction)
    contacts_with_permission
  end

  def self.uncontacted_from_org(org, archived = false)
    permission = OrganizationalPermission.arel_table
    interaction = Interaction.arel_table
    query = OrganizationalPermission
            .where(deleted_at: nil, organization_id: org.id)
            .joins(permission
               .outer_join(interaction)
               .on(permission[:organization_id].eq(interaction[:organization_id])
                     .and(permission[:person_id].eq(interaction[:receiver_id])))
               .join_sources)
            .where(interaction[:id].eq(nil))
    query = query.where(archive_date: nil) unless archived
    query
  end
end
