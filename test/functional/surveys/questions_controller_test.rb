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
      element = Factory(:choice_field)
      @q3 = Factory(:survey_element, element: element)
    end
    
    should "be able to select a predefined or previously used question" do
      xhr :post, :create, { :question_id => @q3.element.id, :survey_id => @org.surveys.first.id}
      assert_response :success
    end
  end
  
  context "show" do
    setup do
      @user, org = admin_user_login_with_org
      @survey = Factory(:survey, organization: org) #create survey
      @question = Factory(:some_question)
      @survey.questions << @question
      assert_equal(@survey.questions.count, 1)
    end
    
    should "show" do
      xhr :get, :show, {:id => @question.id, :survey_id => @survey.id}
      assert_not_nil assigns(:question)
      assert_response :success
    end
  end
  
  context "new" do
    setup do
      @user, org = admin_user_login_with_org
      @survey = Factory(:survey, organization: org) #create survey
      @question = Factory(:some_question)
      @survey.questions << @question
      assert_equal(@survey.questions.count, 1)
    end
    
    should "new" do
      xhr :get, :new, {:survey_id => @survey.id}
      assert_response :success
    end
  end
  
  context "reorder" do
    setup do
      @user, org = admin_user_login_with_org
      @survey = Factory(:survey, organization: org) #create survey
      @question_1 = Factory(:some_question)
      @question_2 = Factory(:some_question)
      @survey.questions << @question_1
      @survey.questions << @question_2
      assert_equal(@survey.questions.count, 2)
    end
    
    should "reorder" do
      a = []
      a << @question_2.id
      a << @question_1.id
      xhr :post, :reorder, {:questions => a, :survey_id => @survey.id}
      assert_response :success
    end
  end
  
  context "create" do
    setup do
      @user, org = admin_user_login_with_org
      @survey = Factory(:survey, organization: org) #create survey
    end
    
    should "create" do
      assert_difference "Question.count" do
        xhr :post, :create, {:question_type => "ChoiceField:radio", :question => {:label => "", :slug => "", :content => "Verge\r\nBarge\r\nTarge", :notify_via => "SMS", :web_only => "0", :hidden => "0"}, :survey_id => @survey.id}
        assert_response :success
      end
    end
  end
  
end
