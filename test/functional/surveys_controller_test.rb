require 'test_helper'

class SurveysControllerTest < ActionController::TestCase
  context "Before logging in" do
    should "redirect on to mhub from non-mhub" do
      @request.host = 'missionhub.com' 
      @survey = Factory(:survey)
      get :start, id: @survey.id 
      assert_redirected_to "http://mhub.cc:80/surveys/#{@survey.id}/start"
    end
    
  end
end
