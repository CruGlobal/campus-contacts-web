class Person < ActiveRecord::Base
  set_table_name 'ministry_person'
  set_primary_key 'personID'
  
  belongs_to :user
  has_many :phone_numbers
  has_one :primary_phone_number, :class_name => "PhoneNumber", :foreign_key => "person_id", :conditions => {:primary => true}
  
  def self.create_from_facebook(data, authentication)
    new.update_from_facebook(data, authentication)
  end
  
  def update_from_facebook(data, authentication)
    self.first_name = data['first_name'] if first_name.blank?
    self.last_name = data['last_name'] if last_name.blank?
    self.birthday = DateTime.strptime(data['birthday'], '%m/%d/%Y') if birthday.blank? && data['birthday'].present?
    self.email = data['email'] if email.blank?
    # For some reason omniauth doesn't give us gender
    self.gender = MiniFB.get(authentication.token, authentication.uid).gender if gender.blank?
    save
    self
  end
end
