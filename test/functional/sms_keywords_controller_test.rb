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
    post :create, { :sms_keyword => { :explanation => "Wat", :state => "requested", :initial_response => "Hi!" } }
  end
  
  test "update" do
    keyword = Factory(:sms_keyword, user: @user, organization: @org)
    post :update, { :id => keyword.id, :sms_keyword => { :explanation => "hahaha" } }
    assert_response :redirect
    assert_equal "hahaha", SmsKeyword.last.explanation.to_s
  end
  
  test "destroy" do
    keyword = Factory(:sms_keyword, user: @user, organization: @org)
    post :destroy, { :id => keyword.id }
    assert_equal 0, SmsKeyword.count
  end
end
