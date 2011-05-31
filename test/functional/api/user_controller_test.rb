require 'test_helper'

class Api::UserControllerTest < ActionController::TestCase
  context "a user action" do
    setup do
      @user = Factory.create(:user_with_auxs)
      @access_token = Factory.create(:access_token)
      @access_token.identity = @user.userID
      @access_token.client_id = 1
      #sign_in @user
      #@person = Factory(:person)
      #@person.fk_ssmUserId = @user.userID
    end
  end
end
