require 'test_helper'

class Apis::V3::PermissionsControllerTest < ActionController::TestCase
  setup do
    request.env['HTTP_ACCEPT'] = 'application/json'
    @client = Factory(:client)
    @user = Factory(:user_no_org)
    @client.organization.add_admin(@user.person)
    @permission = Factory(:permission)
  end

  context '.index' do
    should 'return a list of permissions' do
      get :index, secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal @permission.id, json['permissions'].last['id'], json.inspect
    end
  end


  context '.show' do
    should 'return a permission' do
      get :show, id: @permission.id, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal @permission.name, json['permission']['name']
    end
  end

  context '.create' do
    should 'create and return a permission' do
      assert_difference "Permission.count" do
        post :create, permission: {name: 'funk'}, secret: @client.secret
      end
      json = JSON.parse(response.body)
      assert_equal 'funk', json['permission']['name']
    end
  end

  context '.update' do
    should 'create and return a permission' do
      put :update, id: @permission.id, permission: {name: 'funk'}, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal 'funk', json['permission']['name']
    end
  end

  context '.destroy' do
    should 'create and return a permission' do
      assert_difference "Permission.count", -1 do
        delete :destroy, id: @permission.id, secret: @client.secret
      end
    end
  end



end

