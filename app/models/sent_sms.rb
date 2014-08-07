require 'net/http'
require 'open-uri'
require 'async'
class SentSms < ActiveRecord::Base
  include Async
  include Sidekiq::Worker

  belongs_to :received_sms

  serialize :reports
  serialize :separator
  default_value_for :sent_via, 'twilio'

  # after_create :queue_sms

  def self.smart_split(text, separator=nil, char_limit=160)
    return [text] if text.length <= char_limit
    new_text = ''
    remaining_text = text
    previous_separator = ''
    separator ||= /\s+/
    while match = separator.match(remaining_text)
      text_parts = remaining_text.split(match[0])
      next_chunk = previous_separator + text_parts[0]
      if new_text.length + next_chunk.length > char_limit
        # If the first chunk is already too big, we need to split on space
        if next_chunk.length > char_limit
          return SentSms.smart_split(text)
        else
          too_big = true
          break
        end
      else
        new_text += next_chunk
        previous_separator = match[0]
        remaining_text = text_parts[1..-1].join(' ')
      end
    end
    unless too_big
      next_chunk = previous_separator + text
      new_text += next_chunk if next_chunk.length + new_text.length <= char_limit
    end

    [new_text.strip] + smart_split(text[(new_text.length + 1)..-1].to_s.strip, separator, char_limit)
  end

  def to_twilio
    xml = <<-END
      <Response>
    END
    SentSms.smart_split(message, separator).each do |message|
      xml += <<-END
        <Sms>#{CGI::escapeHTML(message.strip)}</Sms>
      END
    end
    xml += <<-END
      </Response>
    END
  end

  def to_bulksms(url, login, password)

    SentSms.smart_split(message, separator).each_with_index do |message, i|
      msgid = URI.encode("#{id}-#{i+1}")
      msg = URI.encode(message.strip)

      request = "#{url}?username=#{login}&password=#{password}"
      request += "&message=#{msg}&msisdn=#{recipient}"

      begin
        response = open(request).read
        response_hash = response.split("|")
        response_code = response_hash.first.to_i
        self.update_attribute('reports', response_hash)
        if response_code == 0
          puts "Success (#{response_code})"
        else
          puts "Failed (#{response_code})"
        end
      rescue
        puts "Connection Failed"
      end
    end

  end

  def to_smseco
    url = APP_CONFIG['smseco_url']
    login = APP_CONFIG['smseco_username']
    password = APP_CONFIG['smseco_password']
    numero = recipient
    expediteur = "0"

    SentSms.smart_split(message, separator).each_with_index do |message, i|
      msgid = URI.encode("#{id}-#{i+1}")
      msg = URI.encode(message.strip)

      request = "#{url}?login=#{login}&password=#{password}"
      request += "&msgid=#{msgid}&expediteur=#{expediteur}&msg=#{msg}&numero=#{numero}"
      request += "&flash=0&unicode=0&binaire=0"

      begin
        response = open(request).read
        response_hash = Hash.from_xml(response)
        response_code = response_hash['REPONSE']['statut'].to_i
        self.update_attribute('reports', response_hash)
        if response_code == 0
          puts "Success (#{response_code})"
        else
          puts "Failed (#{response_code})"
        end
      rescue
        puts "Connection Failed"
      end
    end
  end

  def queue_sms
    send_sms
    #async(:send_sms)
  end

  private

  def send_sms
    case sent_via
    when 'smseco'
      to_smseco
    when 'bulksms'
      to_bulksms(APP_CONFIG['bulksms_url'], APP_CONFIG['bulksms_username'], APP_CONFIG['bulksms_password'])
    when 'bulksms1'
      to_bulksms(APP_CONFIG['bulksms_url1'], APP_CONFIG['bulksms_username1'], APP_CONFIG['bulksms_password1'])
    else
      if received_sms
        from = received_sms.shortcode
      else
        from = long_code ? long_code.number : SmsKeyword::SHORT
      end

      phone_number = PhoneNumber.find_by_number(recipient)
      if phone_number.present? && !phone_number.not_mobile?
        SentSms.smart_split(message, separator).each do |message|
          begin
            Twilio::SMS.create(:to => recipient, :body => message.strip, :from => from)
          rescue Twilio::APIError => e
            if e.message.include?('is not a mobile number')
              phone_number.not_mobile!
            else
              Airbrake.notify(e)
            end
          end
        end
      end

      long_code.increment!(:messages_sent) if long_code
    end
  end

  def long_code
    unless @long_code
      @long_code = LongCode.active.order(:messages_sent).first
      #raise 'You need to put at least one number in the "long_codes" table' unless @long_code
    end
    @long_code
  end

end
