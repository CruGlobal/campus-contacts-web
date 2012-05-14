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

  context "When updating a question" do
    setup do
      @leader1 = Factory(:user_with_auxs)
      @leader2 = Factory(:user_with_auxs)
      @leader3 = Factory(:user_with_auxs)
      @survey = Factory(:survey, organization: x.organization)
      @element = Factory(:text_field, label: 'foobar')
      @survey_element = Factory(:survey_element, survey: survey, element: element, position: 1, archived: true)
    end

    should "update to-be-notified-leaders" do
      xhr :post, :update, {:text_field =>{:label => @element.label, :content => "", :trigger_words => "Hello", :notify_via => "Email", :web_only => "0"}, :leaders => [@leader1.id], :commit => "Update", :survey_id => @survey.id, :id => @survey_element.id}
      assert_response :success
    end
  end
  
end
