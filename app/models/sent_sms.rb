class SentSms < ActiveRecord::Base
  belongs_to :received_sms
  @queue = :sms
  serialize :reports
  serialize :separator
  default_value_for :sent_via, 'twilio'
  
  after_create :queue_sms
  
  def self.smart_split(text, separator=nil, char_limit=160)
    new_text = ''
    remaining_text = text
    previous_separator = ''
    separator ||= /s+/
    while match = separator.match(remaining_text)
      text_parts = remaining_text.split(match[0])
      next_chunk = previous_separator + text_parts[0]
      if next_chunk.length + new_text.length > char_limit
        too_big = true
        break
      else
        new_text += next_chunk
        previous_separator = match[0]
        remaining_text = text_parts[1]
      end
    end 
    unless too_big
      next_chunk = previous_separator + text 
      new_text += next_chunk if next_chunk.length + new_text.length <= char_limit
    end
    
    [new_text.strip, text[new_text.length..-1].to_s.strip]
  end
  
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
          # from = recipient.first == '1' ? SmsKeyword::SHORT : SmsKeyword::LONG
          from = SmsKeyword::SHORT
        end
        if message.length > 160
          split_message = SentSms.smart_split(message, separator)
          next_message = SentSms.new(attributes.merge(:message => split_message[1]))
          self.message = split_message[0]
        end
        sms = Twilio::SMS.create :to => recipient, :body => message.strip, :from => from
        self.twilio_sid = sms.sid
        self.twilio_uri = sms.uri
      else
        raise "Not sure how to send this sms: sent_via = #{sent_via}"
      end
      save
      if next_message
        sleep(2)
        next_message.save 
      end
      # Log count sent through this carrier (just for fun)
      # if received_sms && received_sms.carrier_name.present?
      #   carrier = SmsCarrier.find_or_create_by_moonshado_name(received_sms.carrier_name) 
      #   carrier.increment!(:sent_sms)
      # end
    end
end
