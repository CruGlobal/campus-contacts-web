require 'test_helper'

class Surveys::QuestionsControllerTest < ActionController::TestCase
  setup do 
    @user, @org = admin_user_login_with_org
    sign_in @user
    Factory(:approved_keyword, organization: @org, user: @user)
    @survey = @org.surveys.first
    @predefined_survey = Factory(:survey, organization: @org)
    APP_CONFIG['predefined_survey'] = @predefined_survey.id
    
  end
  
  test "should get index" do
    element = Factory(:choice_field, label: 'foobar', attribute_name: 'phone_number')
    Factory(:survey_element, survey: @org.surveys.first, element: element, position: 1, archived: true)
  
    APP_CONFIG['predefined_survey'] = Factory(:survey).id
    get :index, survey_id: @survey.id 
    assert_response :success
  end

  #context "When updating a question" do
  #  setup do
  #    @leader1 = Factory(:user_with_auxs)
  #   @leader2 = Factory(:user_with_auxs)
  #   @leader3 = Factory(:user_with_auxs)
  #    @survey = Factory(:survey, organization: x.organization)
  #    @element = Factory(:text_field, label: 'foobar')
  #    @survey_element = Factory(:survey_element, survey: survey, element: element, position: 1, archived: true)
  #  end

    #should "update to-be-notified-leaders" do
    #  xhr :post, :update, {:text_field =>{:label => @element.label, :content => "", :trigger_words => "Hello", :notify_via => "Email", :web_only => "0"}, :leaders => [@leader1.id], :commit => "Update", :survey_id => @survey.id, :id => @survey_element.id}
    #  assert_response :success
    #end
  #end
  
  context "When updating questions" do
    setup do
      element = Factory(:choice_field, label: 'foobar')
      @q1 = Factory(:survey_element, survey: @org.surveys.first, element: element, position: 1, archived: true)
      element = Factory(:choice_field)
      @q2 = Factory(:survey_element, survey: @org.surveys.first, element: element, position: 2)
    end
    
    should "be able to select a predefined or previously used question" do
      puts @org.surveys.inspect
    
      xhr :post, :create, { :question_id => @q2.element.id, :survey_id => @org.surveys.first.id}
      assert_response :success
    end
  end
  
end
