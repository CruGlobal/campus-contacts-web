require 'test_helper'
# curl http://test.ccci.us:7880/sms/mo -d "timestamp=07/07/1982 12:00:00,999&message=asdf&device_address=16304182108&inbound_address=69940&country=US&carrier=sprint"
class SmsControllerTest < ActionController::TestCase
  context "Receiving an incoming SMS" do
    setup do 
      @carrier = Factory(:sms_carrier_sprint)
      @keyword = Factory(:approved_keyword)
      @phone_number = '16304182108'
      @post_params = {message: @keyword.keyword, device_address: @phone_number, 
                      inbound_address: APP_CONFIG['sms_short_code'], country: 'US', carrier: @carrier.moonshado_name}
    end
    
    context "from a known carrier" do
      setup do
        post :mo, @post_params.merge!(timestamp: Time.now.strftime('%m/%d/%Y %H:%M:%S'))
        assert_equal assigns(:received).sms_keyword, @keyword
      end 
      
      should respond_with(:success)
    end
          
    context "using interactive" do
      setup do
        @person = Factory.build(:person_without_name) 
        @person.save(validate: false)
        @sms_session = Factory(:sms_session, person: @person, sms_keyword: @keyword, phone_number: @phone_number)
        @sms_params = @post_params.slice(:message, :carrier, :country).merge(phone_number: @phone_number, shortcode: APP_CONFIG['sms_short_code'], sms_keyword_id: @keyword.id, person: @person)
      end
      
      should "send first survey question when 'i' is texted" do
        Factory(:received_sms, @sms_params)
        post :mo, @post_params.merge(message: 'i', timestamp: Time.now.strftime('%m/%d/%Y %H:%M:%S'))
        assert_equal(assigns(:sms_session).interactive, true)
        assert_equal(assigns(:msg), 'What is your first name?')
      end
      
      should "save response to interactive sms" do
        @sms_session.update_attribute(:interactive, true)
        post :mo, @post_params.merge!({message: 'Jesus', timestamp: Time.now.strftime('%m/%d/%Y %H:%M:%S')})
        assert_equal(assigns(:person).firstName, 'Jesus')
        assert_equal(assigns(:msg), 'What is your last name?')
      end
      
      should "send the first survey question after first and last name are present" do
        @sms_session.update_attribute(:interactive, true)
        @person.update_attribute(:firstName, 'Jesus')
        post :mo, @post_params.merge!({message: 'Christ', timestamp: Time.now.strftime('%m/%d/%Y %H:%M:%S')})
        assert_equal(assigns(:person).lastName, 'Christ')
        assert_equal(assigns(:sent_sms).message, @keyword.questions.first.label_with_choices)
      end
      
      should "convert a letter to a choice option" do
        @sms_session.update_attribute(:interactive, true)
        @person.update_attributes(firstName: 'Jesus', lastName: 'Christ')
        post :mo, @post_params.merge!({message: 'a', timestamp: Time.now.strftime('%m/%d/%Y %H:%M:%S')})
        assert_equal(assigns(:answer_sheet).answers.first.value, 'Prayer Group')
      end
      
      should "save an option typed in" do
        @sms_session.update_attribute(:interactive, true)
        @person.update_attributes(firstName: 'Jesus', lastName: 'Christ')
        post :mo, @post_params.merge!({message: 'Jesus', timestamp: Time.now.strftime('%m/%d/%Y %H:%M:%S')})
        assert_equal(assigns(:answer_sheet).answers.first.value, 'Jesus') 
      end
    end
    
    context "on first sms" do
      should "reply with default message to inactive keyword" do
        @keyword = Factory(:sms_keyword)
        post :mo, @post_params.merge!({message: @keyword.keyword, timestamp: Time.now.strftime('%m/%d/%Y %H:%M:%S')})
        assert_equal(assigns(:sent_sms).message, I18n.t('sms.keyword_inactive'))
      end
    end
    
    context "from an unknown carrier" do
      setup do
        carrier = Factory(:sms_carrier)
        post :mo, @post_params.merge!({carrier: carrier.moonshado_name, timestamp: Time.now.strftime('%m/%d/%Y %H:%M:%S')})
      end
      
      should respond_with(:success)
    end
    
    should "ignore duplicate SMS messages" do
      timestamp = Time.now.strftime('%m/%d/%Y %H:%M:%S')
      post :mo, @post_params.merge!({message: @keyword.keyword, timestamp: timestamp})
      assert_response :success, @response.body
      assert_not_equal(@response.body, ' ')
      
      post :mo, @post_params.merge!({message: @keyword.keyword, timestamp: timestamp})
      assert_response :success, @response.body
      assert_equal(@response.body, ' ')
    end
  end
  
end
