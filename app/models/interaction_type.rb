class InteractionType < ActiveRecord::Base
  attr_accessible :i18n, :icon, :name, :organization_id

  has_many :interactions

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
end
