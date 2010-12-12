require 'test_helper'

class SmsControllerTest < ActionController::TestCase
  context "Receiving an incoming SMS" do
    setup do 
      @post_params = {:timestamp => '07/07/1982 12:00:00', :message => '26am', :device_address => '5555555555', :inbound_address => '123456', :country => 'US'}
    end
    
    context "from a known carrier" do
      setup do
        carrier = Factory(:sms_carrier_sprint)
        post :mo, @post_params.merge({:carrier => carrier.moonshado_name})
      end
      
      should respond_with(:success)
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
