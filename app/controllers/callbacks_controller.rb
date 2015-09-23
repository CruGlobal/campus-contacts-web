class CallbacksController < ApplicationController
  skip_before_filter :authenticate_user!

  def twilio_status
    twilio_sid = params["MessageSid"]
    status = params["MessageStatus"]
    if twilio_sid.blank?
      raise "Error: cannot find message sid parameter from Twilio."
    elsif status.blank?
      raise "Error: cannot find message status parameter from Twilio."
    else
      sent_sms = SentSms.find_by(twilio_sid: twilio_sid)
      sent_sms.update_attributes(status: status) if sent_sms.present?
      render nothing: true
    end
  end
end