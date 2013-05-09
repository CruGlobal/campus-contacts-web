class InteractionType < ActiveRecord::Base
  attr_accessible :i18n, :icon, :name, :organization_id

  has_many :interactions
  
  def title
    i18n || name
  end
end
