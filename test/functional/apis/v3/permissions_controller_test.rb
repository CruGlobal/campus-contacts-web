require 'test_helper'

class Apis::V4::PermissionsControllerTest < ActionController::TestCase
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
end

