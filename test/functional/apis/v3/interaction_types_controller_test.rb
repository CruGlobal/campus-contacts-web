require 'test_helper'

class Apis::V3::InteractionTypesControllerTest < ActionController::TestCase
  setup do
    request.env['HTTP_ACCEPT'] = 'application/json'
    @client = Factory(:client)
    @user = Factory(:user_no_org)
    @org = @client.organization
    @client.organization.add_admin(@user.person)
    @interaction_type = Factory(:interaction_type, organization_id: @client.organization.id)


    @other_org = Factory(:organization)
    @other_org_interaction_type = Factory(:interaction_type, organization_id: @other_org.id)
    @default_interaction_type = Factory(:interaction_type, organization_id: 0)
  end

  context '.index' do
    should 'return a list of interaction_types' do
      get :index, secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal @org.interaction_types.count, json['interaction_types'].count, json.inspect
    end
  end


  context '.show' do
    should 'return a interaction_type' do
      get :show, id: @interaction_type.id, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal @interaction_type.id, json['interaction_type']['id']
    end
  end

  context '.create' do
    should 'create and return a interaction_type' do
      assert_difference "InteractionType.count" do
        post :create, interaction_type: {name: 'type1'}, secret: @client.secret
      end
      json = JSON.parse(response.body)
      assert_equal 'type1', json['interaction_type']['name']
    end
  end

  context '.update' do
    should 'update and return a interaction_type' do
      put :update, id: @interaction_type.id, interaction_type: {name: 'type1'}, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal 'type1', json['interaction_type']['name']
    end
    should "return error when updating default interaction_type" do
      put :update, id: @default_interaction_type.id, interaction_type: {name: 'type1'}, secret: @client.secret
      json = JSON.parse(response.body)
      assert_not_nil json['errors'], json.inspect
    end
  end

  context '.destroy' do
    should 'delete and return a interaction_type' do
      assert_difference "InteractionType.count", -1 do
        delete :destroy, id: @interaction_type.id, secret: @client.secret
      end
    end
    should "not delete default interaction_type" do
      assert_difference "InteractionType.count", 0 do
        delete :destroy, id: @default_interaction_type.id, secret: @client.secret
      end
    end
    should "return error when default interaction_type" do
      delete :destroy, id: @default_interaction_type.id, secret: @client.secret
      json = JSON.parse(response.body)
      assert_not_nil json['errors'], json.inspect
    end
  end



end

