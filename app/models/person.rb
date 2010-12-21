class Person < ActiveRecord::Base
  set_table_name 'ministry_person'
  set_primary_key 'personID'
  
  belongs_to :user, :class_name => 'User', :foreign_key => 'fk_ssmUserId'
  has_many :phone_numbers
  has_one :primary_phone_number, :class_name => "PhoneNumber", :foreign_key => "person_id", :conditions => {:primary => true}
  has_many :email_addresses
  has_one :primary_email_address, :class_name => "EmailAddress", :foreign_key => "person_id", :conditions => {:primary => true}
  validates_presence_of :firstName, :lastName
  
  accepts_nested_attributes_for :email_addresses, :phone_numbers, :allow_destroy => true
  
  
  def self.create_from_facebook(data, authentication)
    new.update_from_facebook(data, authentication)
  end
  
  def update_from_facebook(data, authentication)
    self.firstName = data['first_name'] if firstName.blank?
    self.lastName = data['last_name'] if lastName.blank?
    self.birth_date = DateTime.strptime(data['birthday'], '%m/%d/%Y') if birth_date.blank? && data['birthday'].present?
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
end
