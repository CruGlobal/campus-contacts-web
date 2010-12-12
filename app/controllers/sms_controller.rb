class SmsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :authenticate_user!
  def mo
    # Look for a previous response by this number
    text = ReceivedSms.find_by_phone_number(sms_params[:phone_number])
    if text
      text.response_count.increment!
    else
      text = ReceivedSms.create!(sms_params)
    end
    keyword = SmsKeyword.find_by_keyword(params[:message].split(' ').first)
    
    # If we're sure where the text came from, send generic response
    keyword ||= SmsKeyword.default
    msg =  "Hi! Thanks for checking out #{keyword.name}. Visit http://m.ccci.us/#{keyword.keyword}/#{Base62.encode(text.id)} to get more involved."
    
    # If we're lucky, we can save some coin by replying via email to sms
    carrier = SmsCarrier.find_or_create_by_moonshado_name(text.carrier)
    if carrier.email.present?
      SmsMailer.text("#{text.phone_number}@#{carrier.email}", msg, keyword).deliver
      carrier.increment!(:sent_emails)
      sent_via = 'email'
    else
      sms_id = SMS.deliver(sms_params[:phone_number], msg).first
      carrier.increment!(:sent_sms)
      sent_via = 'moonshado'
    end
    SentSms.create!(:message => msg, :recipient => params[:device_address], :moonshado_claimcheck => sms_id, :sent_via => sent_via, :recieved_sms_id => text.id)
    render :text => text.inspect
  end
  
  protected 
    def sms_params
      unless @sms_params
        @sms_params = params.slice(:carrier, :message, :country)
        @sms_params[:phone_number] = params[:device_address]
        @sms_params[:shortcode] = params[:inbound_address]
        @sms_params[:received_at] = DateTime.strptime(params[:timestamp], '%m/%d/%Y %H:%M:%S')
      end
      @sms_params
    end

end
