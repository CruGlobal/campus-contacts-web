class PhoneNumber < ActiveRecord::Base
  belongs_to :person
  validates_presence_of :number, :location, message: "can't be blank"
  
  before_validation :set_primary, on: :create
  after_destroy :set_new_primary
  
  def self.strip_us_country_code(num)
    return unless num
    num = num.to_s.gsub(/[^\d]/, '')
    num.length == 11 && num.first == '1' ? num[1..-1] : num
  end
  
  def number=(num)
    if num
      self[:number] = PhoneNumber.strip_us_country_code(num)
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
  
  def number_with_country_code
    number.length == 10 ? '1' + number : number
  end
  
  def merge(other)
    PhoneNumber.transaction do
      %w{extension location primary}.each do |k, v|
        next if v == other.attributes[k]
        self[k] = case
                  when other.attributes[k].blank? then v
                  when v.blank? then other.attributes[k]
                  else
                    other.updated_at > updated_at ? other.attributes[k] : v
                  end
      end
      MergeAudit.create!(mergeable: self, merge_looser: other)
      other.destroy
      save(validate: false)
    end
  end
  
  protected
  
  def set_primary
    if person
      self.primary = person.primary_phone_number ? false : true
    end
    true
  end
  
  def set_new_primary
    if self.primary?
      if person && person.phone_numbers.present?
        person.phone_numbers.first.update_attribute(:primary, true)
      end
    end
    true
  end
end
