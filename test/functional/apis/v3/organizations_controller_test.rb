require 'test_helper'

class Apis::V3::OrganizationsControllerTest < ActionController::TestCase
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

    @person = Factory(:person)
    Factory(:email_address, person: @person)
    @org.add_contact(@person)
    @org_label = Factory(:organizational_label, organization: @org, person: @person, label: @label1)

    @another_person = Factory(:person)
    Factory(:email_address, person: @another_person)
    @org.add_contact(@another_person)
    @another_org_label = Factory(:organizational_label, organization: @org, person: @another_person, label: @label1)

    @no_org_person = Factory(:person)
    Factory(:email_address, person: @no_org_person)

    @another_no_org_person = Factory(:person)
    Factory(:email_address, person: @another_no_org_person)

    @child_org1 = Factory(:organization, ancestry: @org.id)
    @child_org2 = Factory(:organization, ancestry: @org.id)
    @child_org3 = Factory(:organization, ancestry: @org.id)
    @non_child_org1 = Factory(:organization)
    @non_child_org2 = Factory(:organization)
  end


  context ".index" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "return a list of organizations" do
        get :index, access_token: @token
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 4, json['organizations'].count, json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "return a list of organizations" do
        get :index, access_token: @token
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 4, json['organizations'].count, json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not return a list of organizations" do
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
      should "return an organization" do
        get :show, access_token: @token, id: @child_org1.id
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @child_org1.id, json['organization']['id'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "return an organization" do
        get :show, access_token: @token, id: @child_org1.id
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @child_org1.id, json['organization']['id'], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not return an organization" do
        get :index, access_token: @token
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
      should "create and return an organization" do
        assert_difference "Organization.count" do
          post :create, access_token: @token,
                organization: {name: "NewOrganization", terminology: "Term"}
        end
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal "NewOrganization", json['organization']['name'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "not create and return an organization" do
        assert_difference "Organization.count", 0 do
          post :create, access_token: @token,
                organization: {name: "NewOrganization"}
        end
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not create and return an organization" do
        assert_difference "Organization.count", 0 do
          post :create, access_token: @token,
                organization: {name: "NewOrganization"}
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
      should "update and return an organization" do
        put :update, access_token: @token, id: @org.id,
              organization: {name: "NewOrganizationName"}
        assert_response :success
        json = JSON.parse(response.body)
        @org.reload
        assert_equal "NewOrganizationName", json['organization']['name'], json.inspect
        assert_equal "NewOrganizationName", @org.name, @org.inspect
      end
      should "not update and return a non current organization" do
        put :update, access_token: @token, id: @child_org1.id,
              organization: {name: "NewOrganizationName"}
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        @non_child_org1.reload
        assert_not_equal "NewOrganizationName", @non_child_org1.name, @non_child_org1.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "not update and return an organization" do
        put :update, access_token: @token, id: @org.id,
            organization: {name: "NewOrganizationName"}
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        @org.reload
        assert_not_equal "NewOrganizationName", @org.name, @org.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not update and and return an organization" do
        put :update, access_token: @token, id: @org.id,
            organization: {name: "NewOrganizationName"}
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
      should "destroy an organization" do
        assert_difference "Organization.count", -1 do
          delete :destroy, access_token: @token, id: @child_org1.id
        end
        assert_response :success
      end
      should "not destroy the current organization" do
        assert_difference "Organization.count", 0 do
          delete :destroy, access_token: @token, id: @org.id
        end
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "not destroy an organization" do
        delete :destroy, access_token: @token, id: @org.id
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not destroy an organization" do
        delete :destroy, access_token: @token, id: @org.id
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end
end

