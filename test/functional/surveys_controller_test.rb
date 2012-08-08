require 'test_helper'

class SurveysControllerTest < ActionController::TestCase
  context "Before logging in" do
    should "redirect on to mhub from non-mhub" do
      @request.host = 'missionhub.com' 
      @survey = Factory(:survey)
      get :start, id: @survey.id 
      assert_redirected_to "http://mhub.cc:80/surveys/#{@survey.id}/start"
    end
    
    should "redirect to sign out" do
      @request.host = 'mhub.cc' 
      @survey = Factory(:survey)
      get :start, id: @survey.id 
      assert_redirected_to "http://mhub.cc/s/#{@survey.id}"
    end
    
    context "start survey no matter what the login option" do
      setup do
        @request.host = "missionhub.com"
      end
      
      should "redirect to mhub when login option is 0" do
        @survey = Factory(:survey, login_option: 0)
        get :start, id: @survey.id
        assert_redirected_to "http://mhub.cc:80/surveys/#{@survey.id}/start"
      end
      
      should "redirect to mhub when login option is 1" do
        @survey = Factory(:survey, login_option: 1)
        get :start, id: @survey.id
        assert_redirected_to "http://mhub.cc:80/surveys/#{@survey.id}/start"
      end
      
      should "redirect to mhub when login option is 2" do
        @survey = Factory(:survey, login_option: 0)
        get :start, id: @survey.id
        assert_redirected_to "http://mhub.cc:80/surveys/#{@survey.id}/start"
      end
      
      should "redirect to mhub when login option is 3" do
        @survey = Factory(:survey, login_option: 3)
        get :start, id: @survey.id
        assert_redirected_to "http://mhub.cc:80/surveys/#{@survey.id}/start"
      end
      
      should "stop" do
        get :stop
        assert_response :redirect
        assert_equal nil, cookies[:survey_mode]
        assert_equal nil, cookies[:keyword]
        assert_equal nil, cookies[:survey_id]
      end
    end
  end
  
  should "get admin index" do
    @user, @org = admin_user_login_with_org
    get :index_admin
    assert_not_nil assigns(:organization)
  end
  
  should "render 404 if no user is logged in" do
    get :index
    assert_response :missing
  end

  test "destroy" do
    request.env["HTTP_REFERER"] = "localhost:3000"
    @user, @org = admin_user_login_with_org
    keyword = Factory(:approved_keyword, user: @user, organization: @org)
    assert_equal 1, @org.surveys.count
    post :destroy, { :id => @org.surveys.first.id }
    assert_equal 0, @org.surveys.count
  end
  
  test "update" do
    @user, @org = admin_user_login_with_org
    keyword = Factory(:approved_keyword, user: @user, organization: @org)
    put :update, { :id => @org.surveys.first.id, :survey => { :title => "wat" } }
    assert_response :redirect
    assert_equal "wat", @org.surveys.first.title
  end
  
  test "create" do
    @user, @org = admin_user_login_with_org
    post :create, { :survey => {:title => "wat", :post_survey_message => "Yeah!", :login_option => 0 } }
    assert_response :redirect
    assert_equal 1, @org.surveys.count
    assert_equal "wat", @org.surveys.first.title
  end
end
