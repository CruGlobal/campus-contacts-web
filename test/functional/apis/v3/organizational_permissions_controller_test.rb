require 'test_helper'

class Apis::V3::OrganizationalPermissionsControllerTest < ActionController::TestCase
  setup do
    request.env['HTTP_ACCEPT'] = 'application/json'
    @client = Factory(:client)
    @user = Factory(:user_no_org)
    @organizational_permission = @client.organization.add_admin(@user.person)
  end

  context '.index' do
    should 'return a list of organizational_permissions' do
      get :index, secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal @organizational_permission.id, json['organizational_permissions'].first['id'], json.inspect
    end
  end

end

