class InteractionType < ActiveRecord::Base
  attr_accessible :i18n, :icon, :name, :organization_id

  has_many :interactions
  
  def title
    i18n || name
  end

  def to_hash
    @hash = {}
    @hash['id'] = id
    @hash['name'] = name
    @hash['icon'] = icon
    @hash['i18n'] = i18n
    @hash['organization_id'] = organization_id
    @hash['created_at'] = created_at
    @hash['updated_at'] = updated_at
    @hash
  end
  
  def self.get_interaction_types_hash(org_id)
    interaction_types = InteractionType.where("organization_id = 0 OR organization_id = ?", org_id).order("id")
    interaction_types.collect(&:to_hash)
  end
end
