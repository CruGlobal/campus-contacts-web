require 'test_helper'

class SavedContactSearchesControllerTest < ActionController::TestCase
  
  setup do
    @user, @org = admin_user_login_with_org
  end
 
  should "get index" do
    get :index
    assert_response :success
  end
  
end
