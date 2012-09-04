require 'test_helper'

class DashboardControllerTest < ActionController::TestCase
  setup do
    @user, @org = admin_user_login_with_org
  end

  test "should get index" do
    Factory(:dashboard_post, visible: true)
    get :index
    assert_not_nil assigns(:dashpost)
    assert_response :success
  end

end
