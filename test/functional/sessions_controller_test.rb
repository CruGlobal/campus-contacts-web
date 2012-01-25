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
    
    should "respond success for non mhub login" do
      get :new
      assert_nil(assigns(:survey))
      assert_response(:success)
    end
    
    should "respond success if login option is 0" do
      @request.cookies['survey_id'] = @survey0.id
      get :new
      assert_not_nil(assigns(:survey))
      assert_equal(assigns(:survey).id, @survey0.id)
      assert_response(:success)
    end
    
    should "respond success if login option is 1" do
      @request.cookies['survey_id'] = @survey1.id
      get :new
      assert_not_nil(assigns(:survey))
      assert_equal(assigns(:survey).id, @survey1.id)
      assert_response(:success)
    end
    
    should "redirect to survey if login option is 2" do
      @request.cookies['survey_id'] = @survey2.id
      get :new
      assert_not_nil(assigns(:survey))
      assert_equal(assigns(:survey).id, @survey2.id)
      assert_response(:redirect)
      assert_redirected_to "/s/#{@survey2.id}?nologin=true"
    end
    
    should "redirect to survey if login option is 3" do
      @request.cookies['survey_id'] = @survey3.id
      get :new
      assert_not_nil(assigns(:survey))
      assert_equal(assigns(:survey).id, @survey3.id)
      assert_response(:redirect)
      assert_redirected_to "/s/#{@survey3.id}?nologin=true"
    end
  end

end
