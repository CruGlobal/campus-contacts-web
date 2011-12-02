require 'test_helper'

class Surveys::QuestionsControllerTest < ActionController::TestCase
  setup do 
    @user = Factory(:user_with_auxs) 
    sign_in @user
    @survey = Factory(:survey, organization: @user.person.primary_organization)
  end
  
  test "should get index" do
    APP_CONFIG['predefined_question_sheet'] = Factory(:survey).id
    get :index, survey_id: @survey.id 
    assert_response :success
  end
end
