require 'test_helper'
# curl http://test.ccci.us:7880/sms/mo -d "timestamp=07/07/1982 12:00:00,999&message=asdf&device_address=16304182108&inbound_address=69940&country=US&carrier=sprint"
class SmsControllerTest < ActionController::TestCase
  context "Receiving an incoming SMS" do
    setup do 
      @post_params = {:timestamp => '07/07/1982 12:00:00,999', :message => APP_CONFIG['sms_default_keyword'], :device_address => '6304182108', :inbound_address => APP_CONFIG['sms_short_code'], :country => 'US'}
    end
    
    context "from a known carrier" do
      setup do
        @carrier = Factory(:sms_carrier_sprint)
        post :mo, @post_params.merge({:carrier => @carrier.moonshado_name})
      end 
      
      should respond_with(:success)
      
      # currently fails
      # should "increment the second time from the same number" do
      #         post :mo, @post_params.merge({:carrier => @carrier.moonshado_name})
      #         assert_equal(2, assigns(:text).response_count)
      #       end
    end
    
    context "from an unknown carrier" do
      setup do
        carrier = Factory(:sms_carrier)
        post :mo, @post_params.merge({:carrier => carrier.moonshado_name})
      end
      
      should respond_with(:success)
    end
  end

end
