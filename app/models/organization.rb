class Organization < ActiveRecord::Base
  has_ancestry
  belongs_to :importable, polymorphic: true
  has_many :activities, dependent: :destroy
  has_many :target_areas, through: :activities
  has_many :organization_memberships, dependent: :destroy
  has_many :people, through: :organization_memberships
  has_many :keywords, class_name: 'SmsKeyword'
  has_many :question_sheets, through: :keywords
  has_many :pages, through: :question_sheets
  has_many :page_elements, through: :pages
  has_many :questions, through: :pages
  has_many :organizational_roles, inverse_of: :organization
  has_many :leaders, through: :organizational_roles, source: :person, conditions: {'organizational_roles.role_id' => Role.leader_ids}, order: "lastName, preferredName, firstName"
  has_many :contacts, through: :organizational_roles, source: :person, conditions: ["organizational_roles.role_id = ? AND organizational_roles.followup_status <> 'do_not_contact'", Role.contact.id]
  has_many :dnc_contacts, through: :organizational_roles, source: :person, conditions: {'organizational_roles.role_id' => Role.contact.id, 'organizational_roles.followup_status' => 'do_not_contact'}
  has_many :completed_contacts, through: :organizational_roles, source: :person, conditions: {'organizational_roles.role_id' => Role.contact.id, 'organizational_roles.followup_status' => 'completed'}
  has_many :inprogress_contacts, through: :organizational_roles, source: :person, conditions: ["organizational_roles.role_id = ? AND organizational_roles.followup_status NOT IN('do_not_contact', 'completed')", Role.contact.id]
  
  validates_presence_of :name
  
  def to_s() name; end
  
  def roles
    Role.where("organization_id = 0 or organization_id = #{id}")
  end
  
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
