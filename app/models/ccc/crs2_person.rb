class Ccc::Crs2Person < ActiveRecord::Base
  establish_connection :uscm

  self.table_name = 'crs2_person'
  has_one :profile, class_name: 'Ccc::Crs2Profile'
  has_many :email_addresses, class_name: 'Ccc::Crs2EmailAddress', foreign_key: :person_id
  has_many :phone_numbers, class_name: 'Ccc::Crs2PhoneNumber', foreign_key: :person_id
  has_one :primary_email_address, class_name: "Ccc::Crs2EmailAddress", foreign_key: "person_id", conditions: {primary: true}

  def email
    @email = primary_email_address.try(:email)
    @email ||= email_addresses.first.try(:email) if email_addresses.present?
    @email ||= self[:email]
    @email
  end

  def all_email_addresses
    emails = email_addresses.collect(&:email)
    emails << self[:email] if self[:email]
    emails.uniq
  end

  def all_phone_numbers
    numbers = phone_numbers.collect(&:number)
    numbers << current_phone if current_phone
    numbers.uniq
  end

  def preferred_or_first
    first_name
  end

  def gender_as_int
    return nil unless gender
    gender == 'Female' ? 0 : 1
  end

  def date_became_christian
    nil
  end

  def minor
    nil
  end

end
