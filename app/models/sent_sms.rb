class SentSms < ActiveRecord::Base
  belongs_to :received_sms
  @queue = :sms
  serialize :reports
  default_value_for :sent_via, 'twilio'
  
  after_create :queue_sms
  
  private
    def queue_sms
      async(:send_sms)
    end
  
    def send_sms
      case sent_via 
      when 'moonshado'
        self.moonshado_claimcheck = SMS.deliver(recipient, message).first # 
      when 'twilio'
        # Figure out which number to send from
        if received_sms
          from = received_sms.shortcode
        else
          # If the recipient is in the US, use the shortcode, otherwise use the long number
          from = recipient.first == '1' ? SmsKeyword::SHORT : SmsKeyword::LONG
        end
        sms = Twilio::SMS.create :to => recipient, :body => message, :from => from
        self.twilio_sid = sms.sid
        self.twilio_uri = sms.uri
      else
        raise "Not sure how to send this sms: sent_via = #{sent_via}"
      end
      save
    
      # Log count sent through this carrier (just for fun)
      if received_sms && received_sms.carrier.present?
        carrier = SmsCarrier.find_or_create_by_moonshado_name(received_sms.carrier) 
        carrier.increment!(:sent_sms)
      end
    end
  
end
