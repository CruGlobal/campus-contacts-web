class SmsSession < AbstractSmsSession
  attr_accessible :sms_keyword_id, :interactive

  belongs_to :sms_keyword

  scope :active,
        -> { where(['updated_at > ? AND ended = ?', 10.minutes.ago, false]) }

  validates_presence_of :sms_keyword_id
end
