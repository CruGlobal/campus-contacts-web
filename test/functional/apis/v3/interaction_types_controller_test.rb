require 'test_helper'

class Apis::V3::InteractionTypesControllerTest < ActionController::TestCase
  setup do
    request.env['HTTP_ACCEPT'] = 'application/json'
    @client = Factory(:client)
    @user = Factory(:user_no_org)
    @client.organization.add_admin(@user.person)
    @interaction_type = Factory(:interaction_type, organization_id: @client.organization.id)
  end

  context '.index' do
    should 'return a list of interaction_types' do
      get :index, secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal @interaction_type.id, json['interaction_types'].last['id'], json.inspect
    end
  end


  context '.show' do
    should 'return a interaction_type' do
      get :show, id: @interaction_type.id, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal @interaction_type.id, json['id']
    end
  end

  context '.create' do
    should 'create and return a interaction_type' do
      assert_difference "InteractionType.count" do
        post :create, interaction_type: {name: 'type1'}, secret: @client.secret
      end
      json = JSON.parse(response.body)
      assert_equal 'type1', json['name']
    end
  end

  context '.update' do
    should 'update and return a interaction_type' do
      put :update, id: @interaction_type.id, interaction_type: {name: 'type1'}, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal 'type1', json['name']
    end
  end

  context '.destroy' do
    should 'delete and return a interaction_type' do
      assert_difference "InteractionType.count", -1 do
        delete :destroy, id: @interaction_type.id, secret: @client.secret
      end
    end
    should "not delete other orgs' interaction_type" do
      @new_org = Factory(:organization)
      @new_interaction_type = Factory(:interaction_type, organization_id: @new_org.id)
      assert_difference "InteractionType.count", 0 do
        delete :destroy, id: @new_interaction_type.id, secret: @client.secret
      end
    end
    should "not delete default interaction_type" do
      @new_interaction_type = Factory(:interaction_type, organization_id: 0)
      assert_difference "InteractionType.count", 0 do
        delete :destroy, id: @new_interaction_type.id, secret: @client.secret
      end
    end
  end



end

