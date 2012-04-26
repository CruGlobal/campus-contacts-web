require 'test_helper'

class Surveys::QuestionsControllerTest < ActionController::TestCase
  setup do 
    @user, @org = admin_user_login_with_org
    sign_in @user
    Factory(:approved_keyword, organization: @org, user: @user)
    @survey = @org.surveys.first
  end
  
  test "should get index" do
    APP_CONFIG['predefined_survey'] = Factory(:survey).id
    get :index, survey_id: @survey.id 
    assert_response :success
  end
  
end
