class InteractionType < ActiveRecord::Base
  attr_accessible :i18n, :icon, :name, :organization_id

  has_many :interactions

  scope :exclude_comment, where("i18n <> 'comment'")

  def title
    i18n || name
  end

  def self.comment
    InteractionType.where(i18n: 'comment', organization_id: 0).try(:first)
  end

  def self.get_interaction_types_hash(org_id)
    interaction_types = InteractionType.where("organization_id = 0 OR organization_id = ?", org_id).order("id")
    interaction_types.collect(&:to_hash)
  end

  def interaction_receivers_from_org(org)
    people_with_interaction = Interaction.where(interaction_type_id: id, organization_id: org.id, deleted_at: nil).collect(&:receiver_id)
    contacts_with_permission = org.all_people.includes(:organizational_permissions).where('organizational_permissions.organization_id' => org.id, 'organizational_permissions.archive_date' => nil, 'organizational_permissions.person_id' => people_with_interaction)
    contacts_with_permission
  end

  def interaction_receivers_from_org_with_archived(org)
    people_with_interaction = Interaction.where(interaction_type_id: id, organization_id: org.id, deleted_at: nil).collect(&:receiver_id)
    contacts_with_permission = org.all_people.includes(:organizational_permissions).where('organizational_permissions.organization_id' => org.id, 'organizational_permissions.person_id' => people_with_interaction)
    contacts_with_permission
  end
end
