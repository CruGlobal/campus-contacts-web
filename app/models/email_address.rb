class EmailAddress < ActiveRecord::Base
  belongs_to :person
  
  before_create :set_primary
  after_destroy :check_for_primary
  
  protected
  
  def set_primary
    self.primary = true unless person.primary_phone_number
  end
  
  def check_for_primary
    if self.primary?
      if person.phone_numbers.present?
        person.phone_numbers.first.update_attribute(:primary, true)
      end
    end
  end
end
