require 'test_helper'

class SmsKeywords::QuestionsControllerTest < ActionController::TestCase
  setup do 
    @user = Factory(:user_with_auxs) 
    sign_in @user
    @keyword = Factory(:approved_keyword)
  end
  
  test "should get index" do
    APP_CONFIG['predefined_question_sheet'] = Factory(:question_sheet).id
    get :index, sms_keyword_id: @keyword.id 
    assert_response :success
  end
end
