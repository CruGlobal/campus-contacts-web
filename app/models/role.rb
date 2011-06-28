class Role < ActiveRecord::Base
  has_many :organizational_roles, inverse_of: :role
  belongs_to :organization, inverse_of: :roles
  scope :default, where(organization_id: 0)
  scope :leaders, where(i18n: %w[leader admin])
  
  def self.leader_ids
    self.leaders.collect(&:id)
  end
  
  def self.admin
    Role.where(i18n: 'admin').first
  end
  
  def self.leader
    Role.where(i18n: 'leader').first
  end
  
  def self.contact
    Role.where(i18n: 'contact').first
  end
  
  def self.involved
    Role.where(i18n: 'involved').first
  end
end
