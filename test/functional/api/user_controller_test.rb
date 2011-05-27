require 'test_helper'

class Api::UserControllerTest < ActionController::TestCase
  context "a user action" do
    setup do
      @user = Factory(:user_with_auxs)
      @access_token = Factory(:access_token)
      @access_token.identity = @user.userID
      @access_token.client_id = 1
      #sign_in @user
      #@person = Factory(:person)
      #@person.fk_ssmUserId = @user.userID
    end
    
    should "request user information" do
      get :user, {'access_token' => @access_token.code, 'id' => "me", 'version' => "v1", 'fields' => 'first_name'}
      #raise @response.inspect
      flunk
    end
  end
end
