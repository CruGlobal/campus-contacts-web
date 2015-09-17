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
      if sent_sms.present?
        sent_sms.update_attributes(status: status)
        render nothing: true
      else
        raise "Error: cannot locate Twilio's message id in the database."
      end
    end
  end
end