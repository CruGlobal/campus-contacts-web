require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  test 'should get index' do
    get :index
    assert_response :success
  end

  should 'redirect when user is logged in' do
    @user, @org = admin_user_login_with_org
    get :index
    assert_response :redirect
  end

  context 'Testing the wizard' do
    setup do
      @user, @org = admin_user_login_with_org
    end

    should 'set redirect to true if there are no surveys present on current org' do
      get :wizard, step: 'keyword'
      assert assigns(:redirect)
      assert_response :redirect
    end

    should 'set redirect to nil if there are surveys in the current org' do
      FactoryGirl.create(:survey, organization: @org)
      get :wizard, step: 'keyword'
      assert_equal nil, assigns(:redirect)
    end

    should 'set redirect to nil if current org is in session on survey step' do
      get :wizard, step: 'survey'
      assert_equal nil, assigns(:redirect)
    end

    should 'set redirect to nil if current org is in session on leaders step' do
      get :wizard, step: 'leaders'
      assert_equal nil, assigns(:redirect)
    end
  end

  should 'get correct template for duplicate' do
    get :duplicate
    assert_template 'layouts/splash'
  end

  should 'get request_access' do
    get :request_access
    assert_not_nil assigns(:request_access)
    assert_template 'layouts/welcome'
  end
end
