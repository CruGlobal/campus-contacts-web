class Organization < ActiveRecord::Base
  has_ancestry
  belongs_to :importable, polymorphic: true
  has_many :activities, dependent: :destroy
  has_many :target_areas, through: :activities
  has_many :organization_memberships, dependent: :destroy
  has_many :people, through: :organizational_roles
  has_many :contact_assignments
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
  has_many :inprogress_contacts, through: :contact_assignments, source: :person
  
  validates_presence_of :name
  
  def to_s() name; end
  
  def children_keywords
    SmsKeyword.where(organization_id: child_ids)
  end
  
  def self_and_children_ids
    @self_and_children_ids ||= [id] + child_ids
  end
  
  def self_and_children_keywords
    SmsKeyword.where(organization_id: self_and_children_ids)
  end
  
  def self_and_children_questions
    @self_and_children_questions ||= self_and_children_keywords.collect(&:questions).flatten.uniq
  end
  
  def unassigned_people
    Person.joins("INNER JOIN organizational_roles ON organizational_roles.person_id = #{Person.table_name}.#{Person.primary_key} AND organizational_roles.organization_id = #{self.id} AND organizational_roles.role_id = '#{Role.contact.id}' AND followup_status <> 'do_not_contact' LEFT JOIN contact_assignments ON contact_assignments.person_id = #{Person.table_name}.#{Person.primary_key}  AND contact_assignments.organization_id = #{self.id}").where('contact_assignments.id' => nil)
  end
  
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
  
  def name_with_keyword_count
    "#{name} (#{keywords.length})"
  end
  
  rails_admin do
    object_label_method {:name_with_keyword_count}
    edit do
      field :name
      field :requires_validation
      field :validation_method, :enum
      field :terminology, :enum do
        help "What do you refer to this organization as? i.e. a Ministry, a Movement, etc"
      end
    end
  end
end
