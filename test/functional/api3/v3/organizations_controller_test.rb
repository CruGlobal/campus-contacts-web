require 'test_helper'

class Api3::V3::OrganizationsControllerTest < ActionController::TestCase
  setup do
    request.env['HTTP_ACCEPT'] = 'application/json'
    @client = Factory(:client)
    @user = Factory(:user_no_org)
    @client.organization.add_admin(@user.person)
    @organization = Factory(:organization, parent: @client.organization)
  end

  context '.index' do
    should 'return a list of organizations' do
      get :index, secret: @client.secret
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['organizations'].length, json.inspect
    end
  end


  context '.show' do
    should 'return a organization' do
      get :show, id: @organization.id, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal @organization.name, json['organization']['name']
    end
  end

  context '.create' do
    should 'create and return a organization' do
      assert_difference "Organization.count" do
        post :create, organization: {name: 'funk', terminology: 'foo'}, secret: @client.secret
      end
      json = JSON.parse(response.body)
      assert_equal 'funk', json['organization']['name']
    end
  end

  context '.update' do
    should 'create and return a organization' do
      put :update, id: @organization.id, organization: {name: 'funk'}, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal 'funk', json['organization']['name']
    end
  end

  context '.destroy' do
    should 'create and return a organization' do
      assert_difference "Organization.count", -1 do
        delete :destroy, id: @organization.id, secret: @client.secret
      end
    end
  end



end

