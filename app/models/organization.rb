class Organization < ActiveRecord::Base
  has_ancestry
  belongs_to :importable, :polymorphic => true
  has_many :activities, :dependent => :destroy
  has_many :target_areas, :through => :activities
  has_many :organization_memberships, :dependent => :destroy
  has_many :people, :through => :organization_memberships
  has_many :keywords, :class_name => 'SmsKeyword'
  has_many :question_sheets, :through => :keywords
  has_many :pages, :through => :question_sheets
  has_many :page_elements, :through => :pages
  has_many :questions, :through => :pages
  has_many :leaders, :through => :organization_memberships, :source => :person, :conditions => 'organization_memberships.leader = 1', :order => "lastName, preferredName, firstName"
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
  
  def question_sheets
    keywords.collect(&:question_sheet)
  end
end
