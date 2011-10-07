class SentSms < ActiveRecord::Base
  belongs_to :received_sms
  @queue = :sms
  serialize :reports
  
  after_create :queue_sms
  
  private
    def queue_sms
      async(:send_sms)
    end
  
    def send_sms
      self.moonshado_claimcheck = SMS.deliver(recipient, message).first #  + ' Txt HELP for help STOP to quit'
      self.sent_via = 'moonshado'
      save
    
      # Log count sent through this carrier (just for fun)
      if received_sms
        carrier = SmsCarrier.find_or_create_by_moonshado_name(received_sms.carrier) 
        carrier.increment!(:sent_sms)
      end
    end
  
end
