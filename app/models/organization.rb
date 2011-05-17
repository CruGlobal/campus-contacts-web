class Organization < ActiveRecord::Base
  has_ancestry
  belongs_to :importable, :polymorphic => true
  has_many :activities, :dependent => :destroy
  has_many :target_areas, :through => :activities
  has_many :organization_memberships, :dependent => :destroy
  has_many :people, :through => :organization_memberships
  validates_presence_of :name
  
  def to_s() name; end
  
  def <=>(other)
    name <=> other.name
  end
  
  def validation_method_enum
    ['relay']
  end
  
  def terminology_enum
    Organization.connection.select_values("select distinct(terminology) term from organizations order by term")
  end
end
