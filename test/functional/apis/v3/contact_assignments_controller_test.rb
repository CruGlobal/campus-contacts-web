require 'test_helper'

class Apis::V3::ContactAssignmentsControllerTest < ActionController::TestCase
  setup do
    request.env["HTTP_ACCEPT"] = "application/json"
    @org = Factory(:organization)
    @client = Factory(:client, organization: @org)

    # Admin
    @user1 = Factory(:user_api)
    @person1 = @user1.person
    @org.add_admin(@person1)
    @admin_token = Factory(:access_token, identity: @user1.id, client_id: @client.id)

    # User
    @user2 = Factory(:user_api)
    @person2 = @user2.person
    @org.add_user(@person2)
    @user_token = Factory(:access_token, identity: @user2.id, client_id: @client.id)

    # No Permission
    @user3 = Factory(:user_api)
    @person3 = @user3.person
    @org.add_contact(@person3, @person1.id, true)
    @no_permission_token = Factory(:access_token, identity: @user3.id, client_id: @client.id)
  end

  context ".index" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "return a list of contact_assignments" do
        get :index, access_token: @token
        json = JSON.parse(response.body)
        assert_equal @org.contact_assignments.count, json["contact_assignments"].count, json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "return a list of contact_assignments" do
        get :index, access_token: @token
        json = JSON.parse(response.body)
        assert_equal @org.contact_assignments.count, json["contact_assignments"].count, json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not return a list of contact_assignments" do
        get :index, access_token: @token
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

  context ".show" do
    setup do
      @sample_person = Factory(:person)
      @org.add_contact(@sample_person)
      @contact_assignment = Factory(:contact_assignment, organization_id: @org.id, assigned_to: @person1, person: @sample_person)
    end
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "return an contact_assignment" do
        get :show, id: @contact_assignment.id, access_token: @token
        json = JSON.parse(response.body)
        assert_equal @contact_assignment.id, json["contact_assignment"]["id"], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "return an organizational_permission" do
        get :show, id: @contact_assignment.id, access_token: @token
        json = JSON.parse(response.body)
        assert_equal @contact_assignment.id, json["contact_assignment"]["id"], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not return an contact_assignment" do
        get :show, id: @contact_assignment.id, access_token: @token
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

  context ".create" do
    setup do
      @new_user = Factory(:user_no_org)
      @new_person = @new_user.person
    end
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "create and return contact_assignment" do
        assert_difference "ContactAssignment.count" do
          post :create, contact_assignment: {assigned_to_id: @person1.id, person_id: @new_person.id}, access_token: @token
        end
        json = JSON.parse(response.body)
        assert_equal @new_person.id, json["contact_assignment"]["person_id"], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "create and return contact_assignment" do
        assert_difference "ContactAssignment.count" do
          post :create, contact_assignment: {assigned_to_id: @person1.id, person_id: @new_person.id}, access_token: @token
        end
        json = JSON.parse(response.body)
        assert_equal @new_person.id, json["contact_assignment"]["person_id"], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not create and return contact_assignment" do
        assert_difference "ContactAssignment.count", 0 do
          post :create, contact_assignment: {assigned_to_id: @person1.id, person_id: @new_person.id}, access_token: @token
        end
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

  context ".update" do
    setup do
      @new_person = Factory(:person)
      @org.add_contact(@new_person)
      @contact_assignment = Factory(:contact_assignment, organization_id: @org.id, assigned_to: @person1, person: @new_person)
      @another_person = Factory(:person)
      @org.add_contact(@another_person)
    end
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "update and return contact_assignment" do
        put :update, id: @contact_assignment.id, contact_assignment: {person_id: @another_person.id}, access_token: @token
        json = JSON.parse(response.body)
        assert_equal @another_person.id, json["contact_assignment"]["person_id"], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "update and return contact_assignment" do
        put :update, id: @contact_assignment.id, contact_assignment: {person_id: @another_person.id}, access_token: @token
        json = JSON.parse(response.body)
        assert_equal @another_person.id, json["contact_assignment"]["person_id"], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not update and return contact_assignment" do
        put :update, id: @contact_assignment.id, contact_assignment: {person_id: @another_person.id}, access_token: @token
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

  context ".destroy" do
    setup do
      @new_person = Factory(:person)
      @org.add_contact(@new_person)
      @contact_assignment = Factory(:contact_assignment, organization_id: @org.id, assigned_to: @person1, person: @new_person)
    end
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "destroy contact_assignment" do
        assert_difference "ContactAssignment.count", -1 do
          delete :destroy, id: @contact_assignment.id, access_token: @token
        end
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "destroy contact_assignment" do
        assert_difference "ContactAssignment.count", -1 do
          delete :destroy, id: @contact_assignment.id, access_token: @token
        end
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not destroy contact_assignment" do
        assert_difference "ContactAssignment.count", 0 do
          delete :destroy, id: @contact_assignment.id, access_token: @token
        end
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

  context ".bulk_update" do
    setup do
      @new_person = Factory(:person)
      @another_person = Factory(:person)
      @org.add_contact(@new_person)
      @org.add_contact(@another_person)
      @contact_assignment1 = Factory(:contact_assignment, organization_id: @org.id, assigned_to: @person2, person: @new_person)
      @contact_assignment2 = Factory(:contact_assignment, organization_id: @org.id, assigned_to: @person2, person: @another_person)
      @admin_person = Factory(:person)
      Factory(:email_address, email: 'admin@email.com', person: @admin_person)
    end
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "update and return contact_assignment" do
        post :bulk_update, contact_assignments: [{id: @contact_assignment1.id, assigned_to_id: @admin_person.id}, {id: @contact_assignment2.id, assigned_to_id: @admin_person.id}], access_token: @token
        json = JSON.parse(response.body)
        assert_equal 2, json["contact_assignments"].count
        assert_equal @admin_person.id, json["contact_assignments"].first["assigned_to_id"]
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "update and return contact_assignment" do
        post :bulk_update, contact_assignments: [{id: @contact_assignment1.id, assigned_to_id: @admin_person.id}, {id: @contact_assignment2.id, assigned_to_id: @admin_person.id}], access_token: @token
        json = JSON.parse(response.body)
        assert_equal 2, json["contact_assignments"].count
        assert_equal @admin_person.id, json["contact_assignments"].first["assigned_to_id"]
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not update and return contact_assignment" do
        post :bulk_update, contact_assignments: [{id: @contact_assignment1.id, assigned_to_id: @admin_person.id}, {id: @contact_assignment2.id, assigned_to_id: @admin_person.id}], access_token: @token
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

  context ".bulk_destroy" do
    setup do
      @new_person = Factory(:person)
      @another_person = Factory(:person)
      @org.add_contact(@new_person)
      @org.add_contact(@another_person)
      @contact_assignment1 = Factory(:contact_assignment, organization_id: @org.id, assigned_to: @person2, person: @new_person)
      @contact_assignment2 = Factory(:contact_assignment, organization_id: @org.id, assigned_to: @person2, person: @another_person)
    end
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "not destroy contact_assignment without filters" do
        post :bulk_destroy, access_token: @token
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
      should "destroy contact_assignment with filters" do
        assert_difference "ContactAssignment.count", -2 do
          post :bulk_destroy, access_token: @token, filters: {ids: "#{@contact_assignment1.id},#{@contact_assignment2.id}"}
        end
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "not destroy contact_assignment without filters" do
        post :bulk_destroy, access_token: @token
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
      should "destroy contact_assignment with filters" do
        assert_difference "ContactAssignment.count", -2 do
          post :bulk_destroy, access_token: @token, filters: {ids: "#{@contact_assignment1.id},#{@contact_assignment2.id}"}
        end
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not destroy contact_assignment without filters" do
        post :bulk_destroy, access_token: @token
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
      should "not destroy contact_assignment with filters" do
        post :bulk_destroy, access_token: @token, filters: {ids: "#{@contact_assignment1.id},#{@contact_assignment2.id}"}
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end
end

