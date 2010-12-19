class EmailAddress < ActiveRecord::Base
  belongs_to :person
  validates_presence_of :person_id, :email, :on => :create, :message => "can't be blank"
  
  before_validation :set_primary, :on => :create
  after_destroy :check_for_primary
  
  protected
  
  def set_primary
    if person
      self.primary = person.primary_email_address ? false : true
    end
    true
  end
  
  def check_for_primary
    if self.primary?
      if person && person.email_addresses.present?
        person.email_addresses.first.update_attribute(:primary, true)
      end
    end
    true
  end
end
