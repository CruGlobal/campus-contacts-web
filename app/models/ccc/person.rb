class Ccc::Person < ActiveRecord::Base

  self.table_name = 'ministry_person'
  self.primary_key = 'personID'


  establish_connection :uscm

  belongs_to :user, class_name: 'Ccc::SimplesecuritymanagerUser', foreign_key: 'fk_ssmUserId'
  has_many :phone_numbers, autosave: true
  has_many :email_addresses, autosave: true
  has_one :primary_phone_number, class_name: 'Ccc::PhoneNumber', foreign_key: 'person_id', conditions: {primary: true}
  has_one :current_address, class_name: "Ccc::MinistryNewaddress", foreign_key: "fk_PersonID", conditions: {addressType: 'current'}


  def email
    @email = primary_email_address.try(:email)
    @email ||= email_addresses.first.try(:email) if email_addresses.present?
    @email ||= (user.username || user.email) if user
    @email ||= current_address.email if current_address
    @email
  end

  def all_phone_numbers
    numbers = phone_numbers.collect(&:number)
    if current_address
      numbers << current_address.homePhone if current_address.homePhone.present?
      numbers << current_address.workPhone if current_address.workPhone.present?
      numbers << current_address.cellPhone if current_address.cellPhone.present?
    end
    numbers
  end

  def all_email_addresses
    emails = email_addresses.collect(&:email)
    if current_address && current_address.email.present?
      emails << current_address.email
    end
    if user
      emails << user.username
      emails << user.email if user.email.present?
    end
    emails
  end


  def preferred_or_first
    preferredName.present? ? preferredName : firstName
  end

  def last_name
    lastName
  end

  def middle_name
    middleName
  end

  def gender_as_int
    gender
  end

  def greek_affiliation
    greekAffiliation
  end

  def year_in_school
    yearInSchool
  end

  def updated_at
    dateChanged
  end
end