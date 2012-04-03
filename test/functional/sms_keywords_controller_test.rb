require 'test_helper'

class SmsKeywordsControllerTest < ActionController::TestCase
  setup do
    @user, @org = admin_user_login_with_org
  end
  
  should "get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:keywords)
  end
  
  should "get new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:sms_keyword)
  end
  
  should "create new sms keyword" do
    post :create, sms_keyword: { explanation: "Wat", state: "requested", initial_response: "Hi!" }
    assert_response :success
  end
end
