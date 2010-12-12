class SmsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def mo
    sms_params[:phone_number] = params[:device_address]
    sms_params = params.slice(:carrier, :message, :country)
    sms_params[:shortcode] = params[:inbound_address]
    sms_params[:received_at] = DateTime.strptime(params[:timestamp], '%m/%d/%Y %H:%M:%S')
    # Look for a previous response by this number
    text = ReceivedSms.find_by_phone_number(sms_params[:phone_number])
    if text
      text.response_count.increment!
    else
      text = RecievedSms.create!(sms_params)
    end
    keyword = Keyword.find_by_keyword(params[:message].split(' ').first)
    if keyword
      msg =  "Hi! Thanks for checking out #{keyword.name}. Visit http://m.ccci.us/#{keyword.keyword}/#{Base62.encode(text.id)} to get more involved."
    else
      # Not sure what campus this is, send generic response
      msg = "Hi! Thanks for checking out Cru. Visit http://m.ccci.us/cru/#{Base62.encode(text.id)} to get more involved."
    end
    # If we're lucky, we can save some coin by replying via email to sms
    if Text::CARRIERS[text.carrier]
      TextMailer.text("#{text.phone_number}@#{Text::CARRIERS[text.carrier]}", msg).deliver
      sent_via = 'email'
    else
      sms_id = Moonshado::Sms.deliver(params[:device_address], msg).first
      sent_via = 'moonshado'
    end
    SentSms.create!(:message => msg, :recipient => params[:device_address], :moonshado_claimcheck => sms_id, :sent_via => sent_via, :recieved_sms_id => text.id)
    render :text => text.inspect
  end

end
