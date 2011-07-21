class SmsSession < ActiveRecord::Base
  belongs_to :person
  belongs_to :sms_keyword
  
  validates_presence_of :phone_number, :person_id, :sms_keyword_id
end
