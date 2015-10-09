require 'test_helper'

class Apis::V3::InteractionTypesControllerTest < ActionController::TestCase
  setup do
    request.env['HTTP_ACCEPT'] = 'application/json'
    @org = FactoryGirl.create(:organization)
    @client = FactoryGirl.create(:client, organization: @org)

    # Admin
    @user1 = FactoryGirl.create(:user_api)
    @person1 = @user1.person
    @org.add_admin(@person1)
    @admin_permission = @person1.permission_for_org_id(@org.id)
    @admin_token = FactoryGirl.create(:access_token, identity: @user1.id, client_id: @client.id)

    # User
    @user2 = FactoryGirl.create(:user_api)
    @person2 = @user2.person
    @org.add_user(@person2)
    @user_permission = @person2.permission_for_org_id(@org.id)
    @user_token = FactoryGirl.create(:access_token, identity: @user2.id, client_id: @client.id)

    # No Permission
    @user3 = FactoryGirl.create(:user_api)
    @person3 = @user3.person
    @org.add_contact(@person3)
    @contact_permission = @person3.permission_for_org_id(@org.id)
    @no_permission_token = FactoryGirl.create(:access_token, identity: @user3.id, client_id: @client.id)

    # Other
    @interaction_type = FactoryGirl.create(:interaction_type, organization_id: @org.id)
    @other_org = FactoryGirl.create(:organization)
    @other_org_interaction_type = FactoryGirl.create(:interaction_type, organization_id: @other_org.id)
    @default_interaction_type = FactoryGirl.create(:interaction_type, organization_id: 0)
  end

  context '.index' do
    context 'ADMIN request' do
      setup do
        @token = @admin_token.code
      end
      should 'return a list of interaction_types' do
        get :index, access_token: @token
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @org.interaction_types.count, json['interaction_types'].count, json.inspect
      end
    end
    context 'USER request' do
      setup do
        @token = @user_token.code
      end
      should 'return a list of interaction_types' do
        get :index, access_token: @token
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @org.interaction_types.count, json['interaction_types'].count, json.inspect
      end
    end
    context 'NO_PERMISSION request' do
      setup do
        @token = @no_permission_token.code
      end
      should 'not return a list of interaction_types' do
        get :index, access_token: @token
        json = JSON.parse(response.body)
        assert_not_nil json['errors'], json.inspect
      end
    end
  end

  context '.show' do
    context 'ADMIN request' do
      setup do
        @token = @admin_token.code
      end
      should 'return a interaction_type' do
        get :show, access_token: @token, id: @interaction_type.id
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @interaction_type.id, json['interaction_type']['id'], json.inspect
      end
    end
    context 'USER request' do
      setup do
        @token = @user_token.code
      end
      should 'return a interaction_type' do
        get :show, access_token: @token, id: @interaction_type.id
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal @interaction_type.id, json['interaction_type']['id'], json.inspect
      end
    end
    context 'NO_PERMISSION request' do
      setup do
        @token = @no_permission_token.code
      end
      should 'not return a interaction_type' do
        get :show, access_token: @token, id: @interaction_type.id
        json = JSON.parse(response.body)
        assert_not_nil json['errors'], json.inspect
      end
    end
  end

  context '.create' do
    context 'ADMIN request' do
      setup do
        @token = @admin_token.code
      end
      should 'create and return a interaction_type' do
        assert_difference 'InteractionType.count', 1 do
          post :create, access_token: @token, interaction_type: { name: 'New InteractionType' }
        end
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 'New InteractionType', json['interaction_type']['name'], json.inspect
      end
    end
    context 'USER request' do
      setup do
        @token = @user_token.code
      end
      should 'not create and return a interaction_type' do
        assert_difference 'InteractionType.count', 0 do
          post :create, access_token: @token, interaction_type: { name: 'New InteractionType' }
        end
        json = JSON.parse(response.body)
        assert_not_nil json['errors'], json.inspect
      end
    end
    context 'NO_PERMISSION request' do
      setup do
        @token = @no_permission_token.code
      end
      should 'not create and return a interaction_type' do
        assert_difference 'InteractionType.count', 0 do
          post :create, access_token: @token, interaction_type: { name: 'New InteractionType' }
        end
        json = JSON.parse(response.body)
        assert_not_nil json['errors'], json.inspect
      end
    end
  end

  context '.update' do
    context 'ADMIN request' do
      setup do
        @token = @admin_token.code
      end
      should 'update and return a interaction_type' do
        put :update, access_token: @token, id: @interaction_type.id,
                     interaction_type: { name: 'New Name' }
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 'New Name', json['interaction_type']['name'], json.inspect
      end
      should 'not update and return a default interaction_type' do
        put :update, access_token: @token, id: @default_interaction_type.id,
                     interaction_type: { name: 'New Name' }
        json = JSON.parse(response.body)
        assert_not_nil json['errors'], json.inspect
      end
    end
    context 'USER request' do
      setup do
        @token = @user_token.code
      end
      should 'not update and return a interaction_type' do
        put :update, access_token: @token, id: @interaction_type.id,
                     interaction_type: { name: 'New Name' }
        json = JSON.parse(response.body)
        assert_not_nil json['errors'], json.inspect
      end
    end
    context 'NO_PERMISSION request' do
      setup do
        @token = @no_permission_token.code
      end
      should 'not update and return a interaction_type' do
        put :update, access_token: @token, id: @interaction_type.id,
                     interaction_type: { name: 'New Name' }
        json = JSON.parse(response.body)
        assert_not_nil json['errors'], json.inspect
      end
    end
  end

  context '.destroy' do
    context 'ADMIN request' do
      setup do
        @token = @admin_token.code
      end
      should 'destroy a interaction_type' do
        assert_difference 'InteractionType.count', -1 do
          delete :destroy, access_token: @token, id: @interaction_type.id
        end
        assert_response :success
      end
      should 'not destroy a default interaction_type' do
        assert_difference 'InteractionType.count', 0 do
          delete :destroy, access_token: @token, id: @default_interaction_type.id
        end
        json = JSON.parse(response.body)
        assert_not_nil json['errors'], json.inspect
      end
    end
    context 'USER request' do
      setup do
        @token = @user_token.code
      end
      should 'not destroy a interaction_type' do
        assert_difference 'InteractionType.count', 0 do
          delete :destroy, access_token: @token, id: @interaction_type.id
        end
        json = JSON.parse(response.body)
        assert_not_nil json['errors'], json.inspect
      end
    end
    context 'NO_PERMISSION request' do
      setup do
        @token = @no_permission_token.code
      end
      should 'not destroy a interaction_type' do
        assert_difference 'InteractionType.count', 0 do
          delete :destroy, access_token: @token, id: @interaction_type.id
        end
        json = JSON.parse(response.body)
        assert_not_nil json['errors'], json.inspect
      end
    end
  end
end
