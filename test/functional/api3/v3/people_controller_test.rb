require 'test_helper'

class Apis::V3::PeopleControllerTest < ActionController::TestCase
  setup do
    request.env['HTTP_ACCEPT'] = 'application/json'
    @client = Factory(:client)
    @person = Factory(:user_no_org).person
    @client.organization.add_admin(@person)
  end

  context '.index' do
    should 'return a list of ppl' do
      get :index, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal 1, json['people'].length, json.inspect
    end
  end


  context '.show' do
    should 'return a person' do
      get :show, id: @person.id, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal @person.first_name, json['person']['first_name']
    end
  end

  context '.create' do
    should 'create and return a person' do
      assert_difference "Person.count" do
        post :create, person: {first_name: 'funk'}, secret: @client.secret
      end
      json = JSON.parse(response.body)
      assert_equal 'funk', json['person']['first_name']
    end
  end

  context '.update' do
    should 'create and return a person' do
      put :update, id: @person.id, person: {first_name: 'funk'}, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal 'funk', json['person']['first_name']
    end
  end

  context '.destroy' do
    should 'create and return a person' do
      delete :destroy, id: @person.id, secret: @client.secret
      assert_equal [], assigns(:person).organizational_roles
    end
  end



end

