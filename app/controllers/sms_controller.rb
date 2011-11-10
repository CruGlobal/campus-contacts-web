class SmsController < ApplicationController
  skip_before_filter :authenticate_user!, :verify_authenticity_token
  def mo
    begin
      # try to save the new message
      @received = ReceivedSms.create!(sms_params)
    rescue ActiveRecord::RecordNotUnique
      # the mysql index just saved us from a duplicate message 
      render nothing: true and return 
    end
    # Process incoming text
    message = sms_params[:message]
    
    # See if this is a sticky session ( prior sms in the past XX minutes )
    @sms_session = SmsSession.where(sms_params.slice(:phone_number)).order('updated_at desc').where(["updated_at > ?", 15.minutes.ago]).first
    
    # Handle STOP and HELP messages
    case message.downcase
    when 'stop'
      @sms_session.update_attribute(:interactive, false)
      @msg = 'You have been unsubscribed from MHub SMS alerts. You will receive no more messages.'
      send_message(@msg, sms_params[:phone_number])
      render text: @msg + "\n" and return
    when 'help'
      @msg = 'MHub SMS. Msg & data rates may apply. Reply STOP to quit. Go to http://mhub.cc/terms for more help.'
      send_message(@msg, sms_params[:phone_number])
      render text: @msg + "\n" and return
    when ''
      render nothing: true and return
    end
    
    # If it is, check for interactive texting
    if @sms_session && (@sms_session.interactive? || message.split(' ').first.downcase == 'i')
      @received.update_attributes(sms_keyword_id: @sms_session.sms_keyword_id, person_id: @sms_session.person_id, sms_session_id: @sms_session.id)
      @person = @sms_session.person
      keyword = @sms_session.sms_keyword
      if keyword
        if !@sms_session.interactive? # they just texted in 'i'
          # We're getting into a sticky session
          create_contact_at_org(@person, @sms_session.sms_keyword.organization)
          @sms_session.update_attribute(:interactive, true)
        else
          # Find the person, save the answer, send the next question
          save_survey_question(keyword, @person, message)
          @person.reload
        end
        @msg = send_next_survey_question(keyword, @person, @sms_session.phone_number)
        unless @msg
          # survey is done. send final message
          @msg = keyword.post_survey_message.present? ? keyword.post_survey_message : t('contacts.thanks.message')
          send_message(@msg, @received.phone_number)
        end
      end
    else
      # We're starting a new sms session
      # Try to find a person with this phone number. If we can't, create a new person
      unless person = Person.includes(:phone_numbers).where('phone_numbers.number' => PhoneNumber.strip_us_country_code(sms_params[:phone_number])).first
        # Create a person record for this phone number
        person = Person.new
        person.save(validate: false)
        person.phone_numbers.create!(number: sms_params[:phone_number], location: 'mobile')
      end
      
      # Look for an active keyword for this message
      keyword = SmsKeyword.find_by_keyword(message.split(' ').first.downcase)
      if !keyword || !keyword.active?
        @msg = t('sms.keyword_inactive')
      else
        @sms_session = SmsSession.create!(person_id: person.id, sms_keyword_id: keyword.id, phone_number: sms_params[:phone_number])
        @msg =  keyword.initial_response.sub(/\{\{\s*link\s*\}\}/, "http://mhub.cc/m/#{Base62.encode(@sms_session.id)}")
        @msg += ' No internet? reply with \'i\''
        @received.update_attributes(sms_keyword_id: keyword.id, person_id: person.id, sms_session_id: @sms_session.id)
      end
      send_message(@msg, sms_params[:phone_number])
    end
    render text: @msg.to_s + "\n"
  end
  
  protected 
    def sms_params
      unless @sms_params
        if params['To'] # Twilio
          @sms_params = {}
          @sms_params[:city] = params['FromCity']
          @sms_params[:state] = params['FromState']
          @sms_params[:zip] = params['FromZip']
          @sms_params[:country] = params['FromCountry']
          @sms_params[:phone_number] = params['From'].sub('+','')
          @sms_params[:shortcode] = params['To']
          @sms_params[:received_at] = Time.now
          @sms_params[:message] = params["Body"].strip.gsub(/\n/, ' ')
        else
          @sms_params = params.slice(:country)
          @sms_params[:carrier_name] = params[:carrier]
          @sms_params[:phone_number] = params[:device_address]
          @sms_params[:shortcode] = params[:inbound_address]
          @sms_params[:received_at] = DateTime.strptime(params[:timestamp], '%m/%d/%Y %H:%M:%S')
          @sms_params[:message] = params[:message].strip.gsub(/\n/, ' ')
        end
      end
      @sms_params
    end
    
    def send_next_survey_question(keyword, person, phone_number)
      question = next_question(keyword, person)
      if question
        msg = question.label
        if question.kind == 'ChoiceField'
          msg = question.label_with_choices
        end
        send_message(msg, phone_number)
      end
      msg
    end
    
    def save_survey_question(keyword, person, answer)
      begin
        case
        when person.firstName.blank?
          person.update_attribute(:firstName, answer)
        when person.lastName.blank?  
          person.update_attribute(:lastName, answer)
        else
          question = next_question(keyword, person)
          @answer_sheet = get_answer_sheet(keyword, person)
          if question
            if question.kind == 'ChoiceField'
              choices = question.choices_by_letter
              # if they typed out a full answer, use that
              answers = answer.gsub(/[^\w]/, '').split(/\s+/).collect {|a| choices.values.detect {|c| c.to_s.downcase == a.to_s.downcase} }.compact
              # if they used letter selections, convert the letter selections to real answers
              answers = answer.gsub(/[^\w]/, '').split(//).collect {|a| choices[a.to_s.downcase]}.compact if answers.empty?
              
              answers = answers.select {|a| a.to_s.strip != ''}
              # only checkbox fields can have more than one answer
              answer = question.style == 'checkbox' ? answers : answers.first
            end
            question.set_response(answer, @answer_sheet)
          end
        end
      rescue => e
        # Don't blow up on bad saves
        HoptoadNotifier.notify(e)
      end
    end
    
    def next_question(keyword, person)
      case
      when person.firstName.blank?
        Question.new(label: "What is your first name?")
      when person.lastName.blank?  
        Question.new(label: "What is your last name?")
      else
        answer_sheet = get_answer_sheet(keyword, person)
        keyword.questions.reload.where(web_only: false).detect {|q| q.responses(answer_sheet).select {|a| a.present?}.blank?}      
      end
    end
    
    def send_message(msg, phone_number)
      sent_via = @sms_params[:shortcode] == '75572' ? 'moonshado' : 'twilio'
      @sent_sms = SentSms.create!(message: msg, recipient: phone_number, received_sms_id: @received.try(:id), sent_via: sent_via)
    end

end
