class Organization < ActiveRecord::Base
  attr_accessor :person_id
    
  has_ancestry
  belongs_to :importable, polymorphic: true
  has_many :roles, inverse_of: :organization
  has_many :group_labels
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
  has_many :all_questions, through: :pages, source: :all_questions
  has_many :followup_comments
  has_many :organizational_roles, inverse_of: :organization
  has_many :leaders, through: :organizational_roles, source: :person, conditions: {'organizational_roles.role_id' => Role.leader_ids}, order: "ministry_person.lastName, ministry_person.preferredName, ministry_person.firstName", uniq: true
  has_many :all_contacts, through: :organizational_roles, source: :person, conditions: ["organizational_roles.role_id = ?", Role::CONTACT_ID]
  has_many :contacts, through: :organizational_roles, source: :person, conditions: ["organizational_roles.role_id = ? AND organizational_roles.followup_status <> 'do_not_contact'", Role::CONTACT_ID]
  has_many :dnc_contacts, through: :organizational_roles, source: :person, conditions: {'organizational_roles.role_id' => Role::CONTACT_ID, 'organizational_roles.followup_status' => 'do_not_contact'}
  has_many :completed_contacts, through: :organizational_roles, source: :person, conditions: {'organizational_roles.role_id' => Role::CONTACT_ID, 'organizational_roles.followup_status' => 'completed'}
  has_many :inprogress_contacts, through: :contact_assignments, source: :person
  has_many :no_activity_contacts, through: :organizational_roles, source: :person, conditions: {'organizational_roles.role_id' => Role::CONTACT_ID, 'organizational_roles.followup_status' => 'uncontacted'}
  has_many :rejoicables
  has_many :groups
  Rejoicable::OPTIONS.each do |option|
    has_many :"#{option}_contacts", :through => :rejoicables, source: :person, conditions: {'rejoicables.what' => option}, uniq: true
  end
  
  validates_presence_of :name#, :person_id
  
  after_create :create_admin_user
  
  def to_s() name; end
  
  def self_and_children
    [self] + children
  end
  
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
    Person.joins("INNER JOIN organizational_roles ON organizational_roles.person_id = #{Person.table_name}.#{Person.primary_key} AND organizational_roles.organization_id = #{self.id} AND organizational_roles.role_id = '#{Role::CONTACT_ID}' AND followup_status <> 'do_not_contact' LEFT JOIN contact_assignments ON contact_assignments.person_id = #{Person.table_name}.#{Person.primary_key}  AND contact_assignments.organization_id = #{self.id}").where('contact_assignments.id' => nil)
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
    "#{name} (#{keywords.count})"
  end
  
  def add_member(person_id)
    OrganizationMembership.find_or_create_by_person_id_and_organization_id(person_id, id) 
  end
  
  def add_leader(person)
    person_id = person.is_a?(Person) ? person.id : person
    add_member(person_id)
    begin
      OrganizationalRole.find_or_create_by_person_id_and_organization_id_and_role_id(person_id, id, Role::LEADER_ID)
    rescue => error
      @save_retry_count =  (@save_retry_count || 5)
      retry if( (@save_retry_count -= 1) > 0 )
      raise error
    end
  end
  
  def add_contact(person)
    person_id = person.is_a?(Person) ? person.id : person
    add_member(person_id)
    begin
      OrganizationalRole.find_or_create_by_person_id_and_organization_id_and_role_id(person_id, id, Role::CONTACT_ID)
    rescue => error
      @save_retry_count =  (@save_retry_count || 5)
      retry if( (@save_retry_count -= 1) > 0 )
      raise error
    end
  end
  
  def add_admin(person)
    person_id = person.is_a?(Person) ? person.id : person
    add_member(person_id)
    OrganizationalRole.find_or_create_by_person_id_and_organization_id_and_role_id(person_id, id, Role::ADMIN_ID)
  end
  
  def add_involved(person)
    person_id = person.is_a?(Person) ? person.id : person
    add_member(person_id)
    OrganizationalRole.find_or_create_by_person_id_and_organization_id_and_role_id(person_id, id, Role::INVOLVED_ID)
  end
  
  def remove_contact(person)
    person_id = person.is_a?(Person) ? person.id : person
    unless Person.find(person_id).organizational_roles.where("organization_id = ? AND role_id <> ?", id, Role::CONTACT_ID).first
      OrganizationMembership.where(person_id: person_id, organization_id: id).first.try(:destroy)
    end
    OrganizationalRole.where(person_id: person_id, organization_id: id, role_id: Role::CONTACT_ID).first.try(:destroy)
  end

  def move_contact(person, to_org)
    remove_contact(person)
    to_org.add_contact(person)
    FollowupComment.where(organization_id: id, contact_id: person.id).update_all(organization_id: to_org.id)
  end

  def create_admin_user
    add_admin(Person.find(self.person_id)) if person_id
  end 

end
