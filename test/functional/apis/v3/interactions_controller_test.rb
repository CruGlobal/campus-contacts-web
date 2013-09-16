require 'test_helper'

class Apis::V3::InteractionsControllerTest < ActionController::TestCase

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
    @person = Factory(:person)
    @org.add_contact(@person)
    @interaction = Factory(:interaction, organization: @org, receiver: @person, creator: @person1, comment: "Comment")

  end

  context ".index" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "return a list of interactions" do
        get :index, access_token: @token
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @interaction.id, json['interactions'].last['id'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "return a list of interactions" do
        get :index, access_token: @token
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @interaction.id, json['interactions'].last['id'], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not return a list of interactions" do
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
      should "return an interaction" do
        get :show, access_token: @token, id: @interaction.id
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @interaction.id, json['interaction']['id'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "return an interaction" do
        get :show, access_token: @token, id: @interaction.id
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @interaction.id, json['interaction']['id'], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not return an interaction" do
        get :show, access_token: @token, id: @interaction.id
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
      should "create and return an interaction" do
        assert_difference "Interaction.count", 1 do
          post :create, access_token: @token, interaction: {receiver_id: @person3.id, comment: 'Comment'}
        end
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 'Comment', json['interaction']['comment'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "create and return an interaction" do
        assert_difference "Interaction.count", 1 do
          post :create, access_token: @token, interaction: {receiver_id: @person3.id, comment: 'Comment'}
        end
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 'Comment', json['interaction']['comment'], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not create and return an interaction" do
        assert_difference "Interaction.count", 0 do
          post :create, access_token: @token, interaction: {receiver_id: @person3.id, comment: 'Comment'}
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
      should "update and return an interaction" do
        @interaction = Factory(:interaction, organization: @org, receiver: @person, creator: @person1, comment: "Comment")
        put :update, access_token: @token, id: @interaction.id,
            interaction: {comment: 'New Comment'}
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 'New Comment', json['interaction']['comment'], json.inspect
      end
      should "not update and return an interaction from other user" do
        @interaction = Factory(:interaction, organization: @org, receiver: @person, creator: @person3, comment: "Comment")
        put :update, access_token: @token, id: @interaction.id,
            interaction: {comment: 'New Comment'}
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        @interaction.reload
        assert_equal "Comment", @interaction.comment, @interaction.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "update and return an interaction" do
        @interaction = Factory(:interaction, organization: @org, receiver: @person, creator: @person2, comment: "Comment")
        put :update, access_token: @token, id: @interaction.id,
            interaction: {comment: 'New Comment'}
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 'New Comment', json['interaction']['comment'], json.inspect
      end
      should "not update and return an interaction from other user" do
        @interaction = Factory(:interaction, organization: @org, receiver: @person, creator: @person3, comment: "Comment")
        put :update, access_token: @token, id: @interaction.id,
            interaction: {comment: 'New Comment'}
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        @interaction.reload
        assert_equal "Comment", @interaction.comment, @interaction.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not update and return an interaction" do
        @interaction = Factory(:interaction, organization: @org, receiver: @person, creator: @person3, comment: "Comment")
        put :update, access_token: @token, id: @interaction.id,
            interaction: {comment: 'New Comment'}
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        @interaction.reload
        assert_equal "Comment", @interaction.comment, @interaction.inspect
      end
      should "not update and return an interaction from other user" do
        @interaction = Factory(:interaction, organization: @org, receiver: @person, creator: @person1, comment: "Comment")
        put :update, access_token: @token, id: @interaction.id,
            interaction: {comment: 'New Comment'}
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        @interaction.reload
        assert_equal "Comment", @interaction.comment, @interaction.inspect
      end
    end
  end



  context ".destroy" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "destroy an interaction" do
        @interaction = Factory(:interaction, organization: @org, receiver: @person, creator: @person1)
        delete :destroy, access_token: @token, id: @interaction.id
        assert_response :success
        json = JSON.parse(response.body)
        @interaction.reload
        assert_not_nil @interaction.deleted_at, json.inspect
      end
      should "not destroy an interaction from other user" do
        @interaction = Factory(:interaction, organization: @org, receiver: @person, creator: @person3)
        delete :destroy, access_token: @token, id: @interaction.id
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        @interaction.reload
        assert_nil @interaction.deleted_at, @interaction.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "destroy an interaction" do
        @interaction = Factory(:interaction, organization: @org, receiver: @person, creator: @person2)
        delete :destroy, access_token: @token, id: @interaction.id
        assert_response :success
        json = JSON.parse(response.body)
        @interaction.reload
        assert_not_nil @interaction.deleted_at, json.inspect
      end
      should "not destroy an interaction from other user" do
        @interaction = Factory(:interaction, organization: @org, receiver: @person, creator: @person3)
        delete :destroy, access_token: @token, id: @interaction.id
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        @interaction.reload
        assert_nil @interaction.deleted_at, @interaction.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "destroy an interaction" do
        @interaction = Factory(:interaction, organization: @org, receiver: @person, creator: @person3)
        delete :destroy, access_token: @token, id: @interaction.id
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        @interaction.reload
        assert_nil @interaction.deleted_at, @interaction.inspect
      end
      should "not destroy an interaction from other user" do
        @interaction = Factory(:interaction, organization: @org, receiver: @person, creator: @person1)
        delete :destroy, access_token: @token, id: @interaction.id
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        @interaction.reload
        assert_nil @interaction.deleted_at, @interaction.inspect
      end
    end
  end

end

