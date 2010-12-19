class PhoneNumber < ActiveRecord::Base
  belongs_to :person
  validates_presence_of :person_id, :number, :location, :on => :create, :message => "can't be blank"
  
  before_validation :set_primary, :on => :create
  after_destroy :check_for_primary
  
  def number=(num)
    if num
      num = num.gsub(/[^\d]/, '')
      self[:number] = num.length == 11 ? num[1..-1] : num
    end
  end
  
  def pretty_number
    case number.length
    when 7
      "#{number[0..2]}-#{number[3..-1]}"
    when 10
      "(#{number[0..2]}) #{number[3..5]}-#{number[6..-1]}"
    else
      number
    end
  end
  
  protected
  
  def set_primary
    if person
      self.primary = person.primary_phone_number ? false : true
    end
    true
  end
  
  def check_for_primary
    if self.primary?
      if person && person.phone_numbers.present?
        person.phone_numbers.first.update_attribute(:primary, true)
      end
    end
    true
  end
end
