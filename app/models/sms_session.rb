class SmsSession < ActiveRecord::Base
  attr_accessible :phone_number, :person_id, :sms_keyword_id, :interactive, :ended

  belongs_to :person
  belongs_to :sms_keyword

  scope :active,
    ->{where(["updated_at > ? AND ended = ?", 10.minutes.ago, false])}

  validates_presence_of :phone_number, :person_id, :sms_keyword_id
end
