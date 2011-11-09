class Role < ActiveRecord::Base
  has_many :people, through: :organizational_roles
  has_many :organizational_roles, inverse_of: :role
  belongs_to :organization, inverse_of: :roles
  belongs_to :organization, inverse_of: :roles
  scope :default, where(organization_id: 0)
  scope :leaders, where(i18n: %w[leader admin])

  validates :i18n, uniqueness: true, allow_nil: true
  validates :name, presence: true, :if => Proc.new { |role| organization_id != 0 }
  
  def self.leader_ids
    self.leaders.collect(&:id)
  end
  
  def self.admin
    Role.find_or_create_by_i18n_and_organization_id('admin', 0)
  end
  
  def self.leader
    Role.find_or_create_by_i18n_and_organization_id('leader', 0)
  end
  
  def self.contact
    Role.find_or_create_by_i18n_and_organization_id('contact', 0)
  end
  
  def self.involved
    Role.find_or_create_by_i18n_and_organization_id('involved', 0)
  end
  
  def to_s
    organization_id == 0 ? I18n.t("roles.#{i18n}") : name
  end
  
  ADMIN_ID = admin.id
  LEADER_ID = leader.id
  CONTACT_ID = contact.id
  INVOLVED_ID = involved.id
  
end
