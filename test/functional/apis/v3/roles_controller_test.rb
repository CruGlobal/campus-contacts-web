require 'test_helper'

class Apis::V3::RolesControllerTest < ActionController::TestCase
  setup do
    request.env['HTTP_ACCEPT'] = 'application/json'
    @client = Factory(:client)
    @user = Factory(:user_no_org)

    @org = @client.organization
    @org.add_admin(@user.person)

    @permission = @user.person.permission_for_org_id(@org.id)
    @label = Factory(:label, organization: @org)

    Factory(:organizational_label, organization: @org, person: @user.person, label: @label)
  end

  context '.index' do
    should 'return a role and labels' do
      get :index, secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal @permission.id, json['roles'].first['id'], json.inspect
      assert_equal @label.id, json['roles'].last['id'], json.inspect
    end
  end


  context '.show' do
    should 'return a permission' do
      get :show, id: @permission.id, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal @permission.name, json['role']['name'], json.inspect
    end
    should 'return a label' do
      get :show, id: @label.id, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal @label.name, json['role']['name'], json.inspect
    end
  end

  context '.create' do
    should 'create and return a label' do
      assert_difference "Label.count" do
        post :create, role: {name: 'sample_label'}, secret: @client.secret
      end
      json = JSON.parse(response.body)
      assert_equal 'sample_label', json['role']['name'], json.inspect
      assert_not_nil json['role']['created_at'], json.inspect
    end
  end

  context '.update' do
    should 'update and return a label' do
      put :update, id: @label.id, role: {name: 'new_label_name'}, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal 'new_label_name', json['role']['name']
    end
  end

  context '.destroy' do
    should 'destroy label' do
      assert_difference "Label.count", -1 do
        delete :destroy, id: @label.id, secret: @client.secret
      end
    end
  end
end

