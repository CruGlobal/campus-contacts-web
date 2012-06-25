class EmailAddress < ActiveRecord::Base
  belongs_to :person
  validates_presence_of :email, on: :create, message: "can't be blank"
  validates_format_of :email, with: /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  before_validation :set_primary, on: :create
  after_destroy :set_new_primary
  validates_uniqueness_of :email, on: :create, message: "already taken"
  
  def to_s
    email
  end
  
  def merge(other)
    EmailAddress.transaction do
      if updated_at && other.primary? && other.updated_at > updated_at
        person.email_addresses.collect {|e| e.update_attribute(:primary, false)}
        new_primary = person.email_addresses.detect {|e| e.email == other.email}
        new_primary.update_attribute(:primary, true) if new_primary
      end
      MergeAudit.create!(mergeable: self, merge_looser: other)
      other.reload
      other.destroy
    end
  end

  def is_unique?
    EmailAddress.where(email: email).blank?
  end
  
  protected
  
  def set_primary
    if person
      if person.primary_email_address && person.primary_email_address.valid?
        self.primary = false
      else
        person.primary_email_address.try(:destroy)
        self.primary = true
      end
    else 
      self.primary = true
    end
    true
  end
  
  def set_new_primary
    if self.primary?
      if person && person.email_addresses.present?
        person.email_addresses.first.update_attribute(:primary, true)
      end
    end
    true
  end



end
