class SmsController < ApplicationController
  skip_before_filter :authenticate_user!, :verify_authenticity_token
  def mo
    # Look for a previous response by this number
    @text = ReceivedSms.where(sms_params.slice(:phone_number, :message)).first
    if @text
      @text.update_attributes(sms_params)
    else
      @text = ReceivedSms.create!(sms_params)
    end
    @text.increment!(:response_count)
    
    keyword = SmsKeyword.find_by_keyword(params[:message].split(' ').first)
    
    if !keyword || !keyword.active?
      msg = t('ma.sms.keyword_inactive')
    else
      msg =  keyword.initial_response.sub(/\{\{\s*link\s*\}\}/, "http://#{request.host_with_port}/m/#{Base62.encode(@text.id)}")
    end

    carrier = SmsCarrier.find_or_create_by_moonshado_name(@text.carrier)
    sms_id = SMS.deliver(sms_params[:phone_number], msg).first
    carrier.increment!(:sent_sms)
    sent_via = 'moonshado'
    SentSms.create!(:message => msg, :recipient => params[:device_address], :moonshado_claimcheck => sms_id, :sent_via => sent_via, :recieved_sms_id => @text.id)
    render :text => @text.inspect
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
