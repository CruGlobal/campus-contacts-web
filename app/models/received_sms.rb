class ReceivedSms < ActiveRecord::Base
  attr_accessible :phone_number, :carrier, :shortcode, :message, :country, :person_id, :received_at, :sms_keyword_id, :sms_session_id, :state, :city, :zip, :twilio_sid

  belongs_to :person
  belongs_to :sms_keyword

  after_commit :trigger_notification, if: Proc.new { self.sms_keyword && self.sms_keyword.mpd? }

  def trigger_notification
    if sms_keyword.mpd? && sms_keyword.mpd_phone_number.present?
      message = "Someone just expressed an interest in your ministry. You might want to give them a call to follow up: #{phone_number}"
      sms = SentSms.create!(received_sms_id: id, message: message, recipient: sms_keyword.mpd_phone_number)
      sms.delay.send_sms
    end
  end

end
