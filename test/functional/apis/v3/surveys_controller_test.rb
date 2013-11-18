require 'test_helper'

class Apis::V3::SurveysControllerTest < ActionController::TestCase

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
    @survey1 = Factory(:survey, organization: @org)
    @survey2 = Factory(:survey, organization: @org)
    @other_org = Factory(:organization)
    @survey3 = Factory(:survey, organization: @other_org)

    @person = Factory(:person)
    Factory(:email_address, person: @person)
    @org.add_contact(@person)
    @org_permission = @org.organizational_permissions.last
  end

  context ".index" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "return a list of surveys" do
        get :index, access_token: @token
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['surveys'].length, json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "return a list of surveys" do
        get :index, access_token: @token
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['surveys'].length, json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not return a list of surveys" do
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
      should "return a survey" do
        get :show, access_token: @token, id: @survey1.id
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @survey1.title, json['survey']['title'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "return a survey" do
        get :show, access_token: @token, id: @survey1.id
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @survey1.title, json['survey']['title'], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not return a survey" do
        get :show, access_token: @token, id: @survey1.id
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
      should "create and return a survey" do
        assert_difference "Survey.count", 1 do
          post :create, access_token: @token,
                survey: {title: 'new_survey', post_survey_message: 'message'}
        end
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 'new_survey', json['survey']['title'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "not create and return a survey" do
        assert_difference "Survey.count", 0 do
          post :create, access_token: @token,
                survey: {title: 'new_survey', post_survey_message: 'message'}
        end
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not create and return a survey" do
        assert_difference "Survey.count", 0 do
          post :create, access_token: @token,
                survey: {title: 'new_survey', post_survey_message: 'message'}
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
      should "update and return a survey" do
        put :update, access_token: @token, id: @survey1.id, survey: {title: 'new_title'}
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 'new_title', json['survey']['title'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "not update and return a survey" do
        put :update, access_token: @token, id: @survey1.id, survey: {title: 'new_title'}
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not update and return a survey" do
        put :update, access_token: @token, id: @survey1.id, survey: {title: 'new_title'}
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
      should "destroy a survey" do
        assert_difference "Survey.count", -1 do
          delete :destroy, access_token: @token, id: @survey1.id
        end
        assert_response :success
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "not destroy a survey" do
        assert_difference "Survey.count", 0 do
          delete :destroy, access_token: @token, id: @survey1.id
        end
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not destroy a survey" do
        assert_difference "Survey.count", 0 do
          delete :destroy, access_token: @token, id: @survey1.id
        end
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end
end

