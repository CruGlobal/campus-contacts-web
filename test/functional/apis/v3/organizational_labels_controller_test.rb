require 'test_helper'

class Apis::V3::OrganizationalLabelsControllerTest < ActionController::TestCase
  setup do
    request.env['HTTP_ACCEPT'] = 'application/json'
    @client = Factory(:client)
    @user = Factory(:user_no_org)
    @client.organization.add_admin(@user.person)
    @label = Factory(:label, organization: @client.organization)
    @organizational_label = Factory(:organizational_label, person: @user.person, organization: @client.organization, label: @label)
  end

  context '.index' do
    should 'return a list of organizational_labels' do
      get :index, secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal @organizational_label.id, json['organizational_labels'].last['id'], json.inspect
    end
  end
end

