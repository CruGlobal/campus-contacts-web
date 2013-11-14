require 'test_helper'

class Apis::V3::AnswersControllerTest < ActionController::TestCase

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
    @user4 = Factory(:user_api)
    @person4 = @user4.person
    @org.add_contact(@person4)

    @survey = Factory(:survey, organization: @org)
    @question = Factory(:text_field, notify_via: "Both", trigger_words: "Short")
    @survey.questions << @question

    @answer_sheet = Factory(:answer_sheet, survey: @survey, person: @person4)
    @answer = Factory(:answer_1, answer_sheet: @answer_sheet, question: @question)
  end

  context ".index" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "return a list of answers" do
        get :index, access_token: @token, question_ids: [@question.id]
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 1, json['answers'].length, json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "return a list of answers" do
        get :index, access_token: @token, question_ids: [@question.id]
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 1, json['answers'].length, json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not return a list of answers" do
        get :index, access_token: @token, question_ids: [@question.id]
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
      should "return a answer" do
        get :show, access_token: @token, id: @answer.id
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @answer.id, json['answer']['id'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "return a answer" do
        get :show, access_token: @token, id: @answer.id
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @answer.id, json['answer']['id'], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not return a answer" do
        get :show, access_token: @token, id: @answer.id
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
      should "create and return a answer" do
        assert_difference "AnswerSheet.count", 1 do
          post :create, access_token: @token, question_id: @question.id, survey_id: @survey.id,
                person_id: @person3, answer: {value: "Answer", short_value: "Ans"}
        end
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @person3.id, json['person']['id'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not create and return a answer" do
        assert_difference "SurveyElement.count", 0 do
          post :create, access_token: @token, survey_id: @survey.id,
                answer: {kind: "TextField", notify_via: "Both", trigger_words: "Short"}
        end
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

end

