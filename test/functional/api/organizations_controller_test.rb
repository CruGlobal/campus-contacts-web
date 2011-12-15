require 'test_helper'

class Api::OrganizationsControllerTest < ActionController::TestCase
  include ApiTestHelper
  
  context "API v1" do
    setup do
      setup_api_env
      
      request.env['HTTP_ACCEPT'] = 'application/vnd.missionhub-v1+json'
      request.env['oauth.access_token'] = @access_token3.code 
    end
    
    should "show an organization" do
      get :show, :id => @temp_org.id
      assert_response :success, @response.body
    end
  end
end
