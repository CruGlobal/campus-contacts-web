require 'digest/md5'
require 'crack/xml'

module Moonshadosms
  API_ENDPOINT = 'api.moonshado.com'
  
  class Sender
    attr_accessor :originating_address, :api_key, :token, :logger, :mailer_callback, :response_callbacks, :default_keyword
    
    def initialize(originating_address, api_key, default_keyword)
      @originating_address = originating_address
      @api_key = api_key
      @keyword = default_keyword
      @response_callbacks = []
    end
    
    def status(moonshado_claimcheck)
      d = {
        :api_key => @api_key,
        :reporting_keys => moonshado_claimcheck
      }
      response = RestClient.get "https://#{API_ENDPOINT}/gateway/reports", :params => d
      return response
    end
    
    def deliver(message, recipients, keyword = default_keyword)
      recipients = recipients.is_a?(Array) ? recipients : [recipients]
      text = prepare_text(message)
      send_time = Time.now
      claimchecks = []
      recipients.each do |recipient|
        claimchecks << moonshado_claimcheck = Digest::MD5.hexdigest(Time.now.to_s + rand.to_s + recipient).to_s
        logger.debug(moonshado_claimcheck)
        d = {
              :api_key => @api_key,
              :message => {
                :reporting_key => moonshado_claimcheck,
                :originating_address => @originating_address,
                :device_address => prepend_country_code(recipient),
                :keyword => keyword,
                :body => text
              }
        }
        begin
          response = RestClient.post "https://#{API_ENDPOINT}/gateway/sms", d
          status = Crack::XML.parse(response)["status"]
          code = status["code"] rescue nil
          info = status["info"] rescue nil
          if code == "10"
            logger.debug("response #{response}") if logger
            logger.debug("Sent #{message} to #{recipient} Info: #{info}") if logger
            response_callbacks.each do |response_callback|
              response_callback.call(:recipient => recipient, :moonshado_claimcheck => moonshado_claimcheck )
            end
          else
            logger.error("Could not send message to #{recipient}. Code: #{code} Info: #{info} Error: #{response}") if logger
            mailer_callback.call("Error in Moonshado SMS", "#{response}") if @mailer_callback
          end
        rescue => e
          logger.error("Caught exception sending message to #{recipient}. Code: #{code} Info: #{info} Error: #{response} Message: #{e.message}") if logger
          mailer_callback.call("Exception in Moonshado SMS", "#{response.body}") if response && @mailer_callback
        end        
      end
      claimchecks
    end
    
    private
    
    def prepend_country_code(number)
      if number =~ /^1/
        number
      else
        "1#{number}"
      end
    end
    
    def prepare_text(message)
      strip_unicode(message)[0..159]
    end
  
    def strip_unicode(message)
      message.unpack("c*").reject {|c| c <0 || c>255}.pack("c*")
    end
  end
end