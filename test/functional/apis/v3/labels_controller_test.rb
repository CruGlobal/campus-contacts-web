require 'test_helper'

class Apis::V3::LabelsControllerTest < ActionController::TestCase

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
    @label1 = Factory(:label, organization: @org)
    @label2 = Factory(:label, organization: @org)

    @default_label = Factory(:label, organization_id: 0)
  end

  context ".index" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "return a list of labels" do
        get :index, access_token: @token
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @org.labels.count, json['labels'].length, json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "return a list of labels" do
        get :index, access_token: @token
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @org.labels.count, json['labels'].length, json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not return a list of labels" do
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
      should "return a label" do
        get :show, access_token: @token, id: @label1.id
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @label1.id, json['label']['id'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "return a label" do
        get :show, access_token: @token, id: @label1.id
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @label1.id, json['label']['id'], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not return a label" do
        get :show, access_token: @token, id: @label1.id
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
      should "create and return a label" do
        assert_difference "Label.count", 1 do
          post :create, access_token: @token, label: {name: "New Label"}
        end
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 'New Label', json['label']['name'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "not create and return a label" do
        assert_difference "Label.count", 0 do
          post :create, access_token: @token, label: {name: "New Label"}
        end
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not create and return a label" do
        assert_difference "Label.count", 0 do
          post :create, access_token: @token, label: {name: "New Label"}
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
      should "update and return a label" do
        put :update, access_token: @token, id: @label1.id,
            label: {name: 'New Name'}
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 'New Name', json['label']['name'], json.inspect
      end
      should "not update and return a default label" do
        put :update, access_token: @token, id: @default_label.id,
            label: {name: 'New Name'}
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "not update and return a label" do
        put :update, access_token: @token, id: @label1.id,
            label: {name: 'New Name'}
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not update and return a label" do
        put :update, access_token: @token, id: @label1.id,
            label: {name: 'New Name'}
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
      should "destroy a label" do
        assert_difference "Label.count", -1 do
          delete :destroy, access_token: @token, id: @label1.id
        end
        assert_response :success
      end
      should "not destroy a default label" do
        assert_difference "Label.count", 0 do
          delete :destroy, access_token: @token, id: @default_label.id
        end
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "not destroy a label" do
        assert_difference "Label.count", 0 do
          delete :destroy, access_token: @token, id: @label1.id
        end
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not destroy a label" do
        assert_difference "Label.count", 0 do
          delete :destroy, access_token: @token, id: @label1.id
        end
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end
end

