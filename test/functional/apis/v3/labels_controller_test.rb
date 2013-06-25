require 'test_helper'

class Apis::V3::LabelsControllerTest < ActionController::TestCase
  setup do
    request.env['HTTP_ACCEPT'] = 'application/json'
    @client = Factory(:client)
    @user = Factory(:user_no_org)

    @org = @client.organization
    @org.add_admin(@user.person)
    @other_org = Factory(:organization)

    @label1 = Factory(:label, organization: @org)
    @label2 = Factory(:label, organization: @org)

    @default_label = Factory(:label, organization_id: 0)
    @other_org_label = Factory(:label, organization: @other_org)
  end

  context '.index' do
    should 'return all labels' do
      get :index, secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal @org.labels.count, json['labels'].count, json.inspect
    end
  end

  context '.show' do
    should 'return a label' do
      get :show, id: @label1.id, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal @label1.name, json['label']['name'], json.inspect
    end
    should 'return a default label' do
      get :show, id: @default_label.id, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal @default_label.name, json['label']['name'], json.inspect
    end
    should 'return error when passing label from other org' do
      get :show, id: @other_org_label.id, secret: @client.secret
      json = JSON.parse(response.body)
      assert_not_nil json['errors'], json.inspect
    end
  end

  context '.create' do
    should 'create and return a label' do
      assert_difference "Label.count" do
        post :create, label: {name: 'sample_label'}, secret: @client.secret
      end
      json = JSON.parse(response.body)
      assert_equal 'sample_label', json['label']['name'], json.inspect
      assert_not_nil json['label']['created_at'], json.inspect
    end
  end

  context '.update' do
    should 'update and return a label' do
      put :update, id: @label1.id, label: {name: 'new_label_name'}, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal 'new_label_name', json['label']['name']
    end
    should 'return error when passing default label' do
      put :update, id: @default_label.id, label: {name: 'new_label_name'}, secret: @client.secret
      json = JSON.parse(response.body)
      assert_not_nil json['errors'], json.inspect
    end
    should 'return error when passing label from other org' do
      put :update, id: @other_org_label.id, label: {name: 'new_label_name'}, secret: @client.secret
      json = JSON.parse(response.body)
      assert_not_nil json['errors'], json.inspect
    end
  end

  context '.destroy' do
    should 'destroy label' do
      assert_difference "Label.count", -1 do
        delete :destroy, id: @label1.id, secret: @client.secret
      end
    end
    should 'return error when passing default label' do
      delete :destroy, id: @default_label.id, secret: @client.secret
      json = JSON.parse(response.body)
      assert_not_nil json['errors'], json.inspect
    end
    should 'return error when passing label from other org' do
      delete :destroy, id: @other_org_label.id, secret: @client.secret
      json = JSON.parse(response.body)
      assert_not_nil json['errors'], json.inspect
    end
  end
end

