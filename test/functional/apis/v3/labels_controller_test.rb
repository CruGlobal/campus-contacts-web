require 'test_helper'

class Apis::V3::LabelsControllerTest < ActionController::TestCase
  setup do
    request.env['HTTP_ACCEPT'] = 'application/json'
    @client = Factory(:client)
    @user = Factory(:user_no_org)
    @client.organization.add_admin(@user.person)
    @label = Factory(:label, organization: @client.organization)
  end

  context '.index' do
    should 'return a list of labels' do
      get :index, secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal @label.id, json['labels'].last['id'], json.inspect
    end
  end


  context '.show' do
    should 'return a label' do
      get :show, id: @label.id, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal @label.name, json['label']['name']
    end
  end

  context '.create' do
    should 'create and return a label' do
      assert_difference "Label.count" do
        post :create, label: {name: 'funk'}, secret: @client.secret
      end
      json = JSON.parse(response.body)
      assert_equal 'funk', json['label']['name']
    end
  end

  context '.update' do
    should 'create and return a label' do
      put :update, id: @label.id, label: {name: 'funk'}, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal 'funk', json['label']['name']
    end
  end

  context '.destroy' do
    should 'create and return a label' do
      assert_difference "Label.count", -1 do
        delete :destroy, id: @label.id, secret: @client.secret
      end
    end
  end



end

