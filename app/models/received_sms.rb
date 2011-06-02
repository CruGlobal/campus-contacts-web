class ReceivedSms < ActiveRecord::Base
  belongs_to :person
  belongs_to :sms_keyword
end
