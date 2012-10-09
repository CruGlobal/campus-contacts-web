require 'test_helper'

class SmsKeywordsControllerTest < ActionController::TestCase
  setup do
    @user, @org = admin_user_login_with_org
  end
  
  should "get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:keywords)
  end
  
  should "accept twilio" do
    request.env["HTTP_REFERER"] = new_sms_keyword_path
    post :accept_twilio
  end
  
  should "get new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:sms_keyword)
  end
  
  context "creating" do
    should "create new sms keyword" do
      survey = Factory(:survey)
      assert_difference "SmsKeyword.count", 1 do
        post :create, {"sms_keyword"=>{"keyword"=>"ha", "explanation"=>"Nothing", "initial_response"=>"Hi! Thanks for checking out Top Level. To get more involved, reply with \"i\" or click {{ link }} if you have a smartphone.", "survey_id"=> survey.id}}
        assert_response :redirect
      end
    end
    
    should "should not create new sms keyword if required fields are not present" do
      assert_no_difference "SmsKeyword.count" do
        post :create, { :sms_keyword => { :explanation => "Wat", :state => "requested", :initial_response => "Hi!" } }
        assert_template "sms_keywords/new"
      end
    end
  end
  
  context "updating" do
    should "update sms keyword" do
      keyword = Factory(:sms_keyword, user: @user, organization: @org)
      post :update, { :id => keyword.id, :sms_keyword => { :explanation => "hahaha" } }
      assert_response :redirect
      assert_equal "hahaha", SmsKeyword.last.explanation.to_s
    end
    
    should "not update sms keyword if required fields are not present" do
      keyword = Factory(:sms_keyword, user: @user, organization: @org)
      post :update, { :id => keyword.id, :sms_keyword => { :explanation => nil } }
      assert_template "sms_keywords/edit"
    end
  end
  
  test "destroy" do
    keyword = Factory(:sms_keyword, user: @user, organization: @org)
    post :destroy, { :id => keyword.id }
    assert_equal 0, SmsKeyword.count
  end
  
=begin
  test "accept twilio" do
    post :accept_twilio
    assert_response :redirect
  end
=end
  
  test "redirect if no current_organization" do
    @user = Factory(:user_no_org)
    sign_in @user
    survey = Factory(:survey)
    post :create, {"sms_keyword"=>{"keyword"=>"ha", "explanation"=>"Nothing", "initial_response"=>"Hi! Thanks for checking out Top Level. To get more involved, reply with \"i\" or click {{ link }} if you have a smartphone.", "survey_id"=> survey.id}}
    assert_redirected_to wizard_path
  end
end
