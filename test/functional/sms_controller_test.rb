require 'test_helper'
# curl http://test.ccci.us:7880/sms/mo -d "timestamp=07/07/1982 12:00:00,999&message=asdf&device_address=16304182108&inbound_address=69940&country=US&carrier=sprint"
class SmsControllerTest < ActionController::TestCase
  context "Receiving an incoming SMS" do
    setup do 
      @carrier = Factory(:sms_carrier_sprint)
      @keyword = Factory(:approved_keyword)
      @post_params = {timestamp: '07/07/1982 12:00:00,999', message: @keyword.keyword, device_address: '6304182108', 
                      inbound_address: APP_CONFIG['sms_short_code'], country: 'US', carrier: @carrier.moonshado_name}
    end
    
    context "from a known carrier" do
      setup do
        post :mo, @post_params
        assert_equal assigns(:text).sms_keyword, @keyword
      end 
      
      should respond_with(:success)
      
      should "increment the second time from the same number" do
        post :mo, @post_params
        assert_equal(2, assigns(:text).response_count)
      end
      
      should "send first survey question 'i' is texted" do
        post :mo, @post_params.merge!({message: 'i'})
        assert_equal(assigns(:sent_sms).message, @keyword.question_sheet.questions.first.label_with_choices)
        # save reply
        post :mo, @post_params.merge!({message: 'Jesus'})
        assert_equal(@keyword.questions.first.display_response(assigns(:answer_sheet)), 'Jesus') 
        # Response should be thanks message
        assert_equal(assigns(:sent_sms).message, @keyword.post_survey_message)
      end
      
    end
      
    context "on first sms" do
      should "reply with default message to inactive keyword" do
        @keyword = Factory(:sms_keyword)
        post :mo, @post_params.merge!({message: @keyword.keyword})
        assert_equal(assigns(:sent_sms).message, I18n.t('ma.sms.keyword_inactive'))
      end
    end
    
    context "from an unknown carrier" do
      setup do
        carrier = Factory(:sms_carrier)
        post :mo, @post_params.merge!({carrier: carrier.moonshado_name})
      end
      
      should respond_with(:success)
    end
  end

end
