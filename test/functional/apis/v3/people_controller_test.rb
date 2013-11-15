require 'test_helper'

class Apis::V3::PeopleControllerTest < ActionController::TestCase
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
    @org_permission = @org.organizational_permissions.last

    @another_person = Factory(:person)
    Factory(:email_address, person: @another_person)
    @org.add_contact(@another_person)
    @another_org_permission = @org.organizational_permissions.last

    @no_org_person = Factory(:person)
    Factory(:email_address, person: @no_org_person)

    @another_no_org_person = Factory(:person)
    Factory(:email_address, person: @another_no_org_person)
  end

  context ".index" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "return a list of people" do
        get :index, access_token: @token
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @org.people.count, json['people'].count, json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "return a list of people" do
        get :index, access_token: @token
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @org.people.count, json['people'].count, json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not return a list of people" do
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
      should "return a person" do
        get :show, access_token: @token, id: @person.id
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @person.id, json['person']['id'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "return a person" do
        get :show, access_token: @token, id: @person.id
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @person.id, json['person']['id'], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not return a person" do
        get :show, access_token: @token, id: @person.id
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
      should "create and return a person" do
        assert_difference "Person.count" do
          post :create, access_token: @token,
                person: {first_name: "FirstName", last_name: "LastName"}
        end
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal "FirstName", json['person']['first_name'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "create and return a person" do
        assert_difference "Person.count" do
          post :create, access_token: @token,
                person: {first_name: "FirstName", last_name: "LastName"}
        end
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal "FirstName", json['person']['first_name'], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not create and return a person" do
        assert_difference "Person.count", 0 do
          post :create, access_token: @token,
                person: {first_name: "FirstName", last_name: "LastName"}
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
      should "update and return a person" do
        post :update, access_token: @token, id: @person.id,
              person: {first_name: "FirstName"}
        assert_response :success
        json = JSON.parse(response.body)
        @person.reload
        assert_equal "FirstName", json['person']['first_name'], json.inspect
        assert_equal "FirstName", @person.first_name
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "update and return a person" do
        post :update, access_token: @token, id: @person.id,
              person: {first_name: "FirstName"}
        assert_response :success
        json = JSON.parse(response.body)
        @person.reload
        assert_equal "FirstName", json['person']['first_name'], json.inspect
        assert_equal "FirstName", @person.first_name
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not update and return a person" do
        post :update, access_token: @token, id: @person,
              person: {first_name: "FirstName"}
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
      should "destroy a person" do
        delete :destroy, access_token: @token, id: @person.id
        assert_response :success
        @org_permission.reload
        assert_not_nil @org_permission.deleted_at
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "destroy a person" do
        delete :destroy, access_token: @token, id: @person.id
        assert_response :success
        @org_permission.reload
        assert_not_nil @org_permission.deleted_at
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not destroy a person" do
        delete :destroy, access_token: @token, id: @person.id
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        @org_permission.reload
        assert_nil @org_permission.deleted_at
      end
    end
  end
end

