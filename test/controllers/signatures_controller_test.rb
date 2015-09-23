require 'test_helper'
class SignaturesControllerTest < ActionController::TestCase
  context "Testing the action_for_signature" do
    setup do
      @user, @org = admin_user_login_with_org
      sign_in(@user)
    end
    should "should get code_of_conduct" do
      get :code_of_conduct
      assert_response :success
    end
    should "should get statement_of_faith" do
      get :statement_of_faith
      assert_response :success
    end
    should "set signature code_of_conduct's status: accepted" do
      post :action_for_signature, { kind: "code_of_conduct", status: "accepted" }
      assert_equal 1, Signature.where(kind: "code_of_conduct", status: "accepted").count
      assert_redirected_to statement_of_faith_signatures_path
    end
    should "set signature statement_of_faith's status: accepted" do
      post :action_for_signature, { kind: "code_of_conduct", status: "accepted" }
      post :action_for_signature, { kind: "statement_of_faith", status: "accepted" }
      assert_equal 1, Signature.where(kind: "statement_of_faith", status: "accepted").count
      assert_redirected_to root_path
      assert_equal I18n.t("signatures.signed_a_signature"), assigns(:msg)
    end
    should "when declined any of the signatures" do
      post :action_for_signature, { kind: "code_of_conduct", status: "accepted" }
      post :action_for_signature, { kind: "statement_of_faith", status: "declined" }
      assert_equal 1, Signature.where(kind: "statement_of_faith", status: "declined").count
      assert_redirected_to root_path
      assert_equal I18n.t("signatures.declined_a_signature"), assigns(:msg)
    end
  end
end