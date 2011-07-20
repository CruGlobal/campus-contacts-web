require 'test_helper'
# curl http://test.ccci.us:7880/sms/mo -d "timestamp=07/07/1982 12:00:00,999&message=asdf&device_address=16304182108&inbound_address=69940&country=US&carrier=sprint"
class SmsControllerTest < ActionController::TestCase
  context "Receiving an incoming SMS" do
    setup do 
      @carrier = Factory(:sms_carrier_sprint)
      @keyword = Factory(:approved_keyword)
      @post_params = {timestamp: '07/07/1982 12:00:00,999', message: @keyword.keyword, device_address: '16304182108', 
                      inbound_address: APP_CONFIG['sms_short_code'], country: 'US', carrier: @carrier.moonshado_name, hash: next_hash}
    end
    
    context "from a known carrier" do
      setup do
        post :mo, @post_params.merge!(hash: next_hash)
        assert_equal assigns(:text).sms_keyword, @keyword
      end 
      
      should respond_with(:success)
      
      # should "increment the second time from the same number" do
      #   post :mo, {}#@post_params.merge!(hash: next_hash)
      #   assert_not_equal(@response.body, ' ')
      #   assert_equal(2, assigns(:text).response_count)
      # end
      
      # should "send first survey question 'i' is texted" do
      #   post :mo, @post_params.merge!({message: 'i', hash: next_hash})
      #   assert_equal(assigns(:sent_sms).message, 'What is your first name?')
      #   # save reply
      #   post :mo, @post_params.merge!({message: 'Jesus', hash: next_hash})
      #   assert_equal(assigns(:text).person.firstName, 'Jesus') 
      # end
      
    end
      
    context "on first sms" do
      should "reply with default message to inactive keyword" do
        @keyword = Factory(:sms_keyword)
        post :mo, @post_params.merge!({message: @keyword.keyword, hash: next_hash})
        assert_equal(assigns(:sent_sms).message, I18n.t('sms.keyword_inactive'))
      end
    end
    
    context "from an unknown carrier" do
      setup do
        carrier = Factory(:sms_carrier)
        post :mo, @post_params.merge!({carrier: carrier.moonshado_name, hash: next_hash})
      end
      
      should respond_with(:success)
    end
    
    should "ignore duplicate SMS messages" do
      post :mo, @post_params.merge!({message: @keyword.keyword, hash: next_hash})
      assert_response :success, @response.body
      assert_not_equal(@response.body, ' ')
      
      post :mo, @post_params.merge!({message: @keyword.keyword, hash: next_hash})
      assert_response :success, @response.body
      assert_equal(@response.body, ' ')
    end
  end
  
  def next_hash
    (Time.now.to_i + Factory.next(:count) + rand(99999)).to_s
  end

end
