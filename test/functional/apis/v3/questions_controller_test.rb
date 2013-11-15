require 'test_helper'

class Apis::V3::QuestionsControllerTest < ActionController::TestCase

  setup do
    request.env["HTTP_ACCEPT"] = "application/json"
    @org = Factory(:organization)
    @client = Factory(:client, organization: @org)

    # Admin
    @user1 = Factory(:user_api)
    @person1 = @user1.person
    @org.add_admin(@person1)
    @admin_permission = @person1.permission_for_org_id(@org.id)
    @admin_token = Factory(:access_token, identity: @user1.id, client_id: @client.id)

    # User
    @user2 = Factory(:user_api)
    @person2 = @user2.person
    @org.add_user(@person2)
    @user_permission = @person2.permission_for_org_id(@org.id)
    @user_token = Factory(:access_token, identity: @user2.id, client_id: @client.id)

    # No Permission
    @user3 = Factory(:user_api)
    @person3 = @user3.person
    @org.add_contact(@person3)
    @contact_permission = @person3.permission_for_org_id(@org.id)
    @no_permission_token = Factory(:access_token, identity: @user3.id, client_id: @client.id)

    # Other
    @survey = Factory(:survey, organization: @org)
    @question1 = Factory(:choice_field, notify_via: "Both", trigger_words: "Word")
    @question2 = Factory(:text_field, notify_via: "Both", trigger_words: "Short")
    @survey.questions << @question1
    @survey.questions << @question2
  end

  context ".index" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "return a list of questions" do
        get :index, access_token: @token, survey_id: @survey.id
        json = JSON.parse(response.body)
        assert_equal 2, json['questions'].length, json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "return a list of questions" do
        get :index, access_token: @token, survey_id: @survey.id
        json = JSON.parse(response.body)
        assert_equal 2, json['questions'].length, json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not return a list of questions" do
        get :index, access_token: @token
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

  context ".show" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "return a question" do
        get :show, access_token: @token, survey_id: @survey.id, id: @question1.id
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @question1.id, json['choice_field']['id'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "return a question" do
        get :show, access_token: @token, survey_id: @survey.id, id: @question1.id
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @question1.id, json['choice_field']['id'], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not return a question" do
        get :show, access_token: @token, survey_id: @survey.id, id: @question1.id
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

  context ".create" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "create and return a question" do
        assert_difference "SurveyElement.count", 1 do
          post :create, access_token: @token, survey_id: @survey.id,
                question: {kind: "TextField", notify_via: "Both", trigger_words: "Short"}
        end
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 'Short', json['text_field']['trigger_words'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "not create and return a question" do
        assert_difference "SurveyElement.count", 0 do
          post :create, access_token: @token, survey_id: @survey.id,
                question: {kind: "TextField", notify_via: "Both", trigger_words: "Short"}
        end
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not create and return a question" do
        assert_difference "SurveyElement.count", 0 do
          post :create, access_token: @token, survey_id: @survey.id,
                question: {kind: "TextField", notify_via: "Both", trigger_words: "Short"}
        end
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

  context ".update" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "update and return a question" do
        put :update, access_token: @token,
            survey_id: @survey.id, id: @question1.id, question: {trigger_words: 'new_word'}
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 'new_word', json['choice_field']['trigger_words'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "not update and return a question" do
        put :update, access_token: @token,
            survey_id: @survey.id, id: @question1.id, question: {trigger_words: 'new_word'}
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not update and return a question" do
        put :update, access_token: @token,
            survey_id: @survey.id, id: @question1.id, question: {trigger_words: 'new_word'}
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

  context ".destroy" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "destroy a question" do
        assert_difference "SurveyElement.count", -1 do
          delete :destroy, access_token: @token, survey_id: @survey.id, id: @question1.id
        end
        assert_response :success
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "not destroy a question" do
        assert_difference "SurveyElement.count", 0 do
          delete :destroy, access_token: @token, survey_id: @survey.id, id: @question1.id
        end
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not destroy a question" do
        assert_difference "SurveyElement.count", 0 do
          delete :destroy, access_token: @token, survey_id: @survey.id, id: @question1.id
        end
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end
end

