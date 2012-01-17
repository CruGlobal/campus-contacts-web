require 'test_helper'

class SessionsControllerTest < ActionController::TestCase

  context "Redirect depending on login option" do
    setup do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      @survey0 = Factory(:survey, login_option: 0)
      @survey1 = Factory(:survey, login_option: 1)
      @survey2 = Factory(:survey, login_option: 2)
      @survey3 = Factory(:survey, login_option: 3)
    end
    
    should "respond success if login option is 0" do
      get :new
      @request.cookies["survey_id"] = CGI::Cookie.new("survey_id", @survey0.id)
      assert_response(:success)
    end
    
    should "respond success if login option is 1" do
      get :new
      @request.cookies["survey_id"] = CGI::Cookie.new("survey_id", @survey1.id)
      assert_response(:success)
    end
    
    should "redirect to survey if login option is 2" do
      get :new
      @request.cookies["survey_id"] = CGI::Cookie.new("survey_id", @survey2.id)
      assert_equal(cookies[:survey_id].first, @survey2.id)
      assert_response(:success)
    end
    
    should "redirect to survey if login option is 3" do
      get :new
      @request.cookies["survey_id"] = CGI::Cookie.new("survey_id", @survey3.id)
      assert_equal(cookies[:survey_id].first, @survey3.id)
      assert_response(:success)
    end
  end

end
