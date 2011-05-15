class Person < ActiveRecord::Base
  include Ccc::Person
  set_table_name 'ministry_person'
  set_primary_key 'personID'
  
  belongs_to :user, :class_name => 'User', :foreign_key => 'fk_ssmUserId'
  has_many :phone_numbers
  has_one :primary_phone_number, :class_name => "PhoneNumber", :foreign_key => "person_id", :conditions => {:primary => true}
  has_many :email_addresses
  has_one :primary_email_address, :class_name => "EmailAddress", :foreign_key => "person_id", :conditions => {:primary => true}
  has_many :organization_memberships
  has_many :organizations, :through => :organization_memberships
  has_one :primary_organization_membership, :class_name => "OrganizationMembership", :foreign_key => "person_id", :conditions => {:primary => true}
  has_one :primary_organization, :through => :primary_organization_membership, :source => :organization
  validates_presence_of :firstName, :lastName
  
  accepts_nested_attributes_for :email_addresses, :phone_numbers, :allow_destroy => true
  
  def to_s
    [preferredName.blank? ? firstName : preferredName, lastName].join(' ')
  end
#We'll do this better at some point.  
#New->Create? Gets rid of the save in update_from_facebook  
  def self.create_from_facebook(data, authentication)
    new.update_from_facebook(data, authentication) 
  end
  
  def update_from_facebook(data, authentication)
    self.firstName = data['first_name'] if firstName.blank?
    self.lastName = data['last_name'] if lastName.blank?
    self.birth_date = DateTime.strptime(data['birthday'], '%m/%d/%Y') if birth_date.blank? && data['birthday'].present?
    save
    unless email_addresses.detect {|e| e.email == data['email']}
      email_addresses.create(:email => data['email'])
    end
    # For some reason omniauth doesn't give us gender
    self.gender = MiniFB.get(authentication.token, authentication.uid).gender if gender.blank?
    save
    self
  end
  
  def gender=(gender)
    if ['male','female'].include?(gender.to_s.downcase)
      self[:gender] = gender.downcase == 'male' ? '1' : '0'
    else
      self[:gender] = gender
    end
  end
  
  def gender
    if ['1','0'].include?(self[:gender])
      self[:gender] == '1' ? 'male' : 'female'
    else
      self[:gender]
    end
  end
  
  def email
    primary_email_address
  end
  
  def email=(val)
    email = primary_email_address || email_addresses.new
    email.email = val
    email.save
  end
  
  def merge(other)
    # Phone Numbers
    phone_numbers.each do |pn|
      opn = other.phone_numbers.detect {|oa| oa.number == pn.number && oa.extension == pn.extension}
      pn.merge(opn) if opn
    end
    other.phone_numbers.each {|pn| pn.update_attribute(:person_id, id) unless pn.frozen?}
    
    # Email Addresses
    email_addresses.each do |pn|
      opn = other.email_addresses.detect {|oa| oa.email == pn.email}
      pn.merge(opn) if opn
    end
    other.email_addresses.each {|pn| pn.update_attribute(:person_id, id) unless pn.frozen?}
    
    # Organizational Memberships
    organization_memberships.each do |pn|
      opn = other.organization_memberships.detect {|oa| oa.organization_id == pn.organization_id}
      pn.merge(opn) if opn
    end
    other.organization_memberships.each {|pn| pn.update_attribute(:person_id, id) unless pn.frozen?}
    
    super
  end
end
