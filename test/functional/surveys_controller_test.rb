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
      assert_redirected_to "http://mhub.cc/sign_out?next=http%3A%2F%2Fmhub.cc%2Fs%2F#{@survey.id}"
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
    end
  end
end
