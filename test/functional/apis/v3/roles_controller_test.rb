require 'test_helper'

class Apis::V3::RolesControllerTest < ActionController::TestCase
  setup do
    request.env['HTTP_ACCEPT'] = 'application/json'
    @client = Factory(:client)
    @user = Factory(:user_no_org)
    @client.organization.add_admin(@user.person)
    @role = Factory(:role, organization: @client.organization)
  end

  context '.index' do
    should 'return a list of roles' do
      get :index, secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal @role.id, json['roles'].last['id'], json.inspect
    end
  end


  context '.show' do
    should 'return a role' do
      get :show, id: @role.id, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal @role.name, json['role']['name']
    end
  end

  context '.create' do
    should 'create and return a role' do
      assert_difference "Role.count" do
        post :create, role: {name: 'funk'}, secret: @client.secret
      end
      json = JSON.parse(response.body)
      assert_equal 'funk', json['role']['name']
    end
  end

  context '.update' do
    should 'create and return a role' do
      put :update, id: @role.id, role: {name: 'funk'}, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal 'funk', json['role']['name']
    end
  end

  context '.destroy' do
    should 'create and return a role' do
      assert_difference "Role.count", -1 do
        delete :destroy, id: @role.id, secret: @client.secret
      end
    end
  end



end

