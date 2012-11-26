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

    should 'create a phone number when the phone number attribute is passed' do
      assert_difference "PhoneNumber.count" do
        post :create, person: {first_name: 'funk', phone_number: '555-555-5555'},
                      secret: @client.secret
      end
    end

    should 'create a phone number when a nested phone number object is passed' do
      assert_difference "PhoneNumber.count" do
        post :create, person: {first_name: 'funk',
                               phone_numbers_attributes: [number: '555-555-5555']},
                      secret: @client.secret
      end
    end

    should 'create a email address when the email address attribute is passed' do
      assert_difference "EmailAddress.count" do
        post :create, person: {first_name: 'funk', email: 'foo@example.com'},
                      secret: @client.secret
      end
    end

    should 'create a email address when a nested email address object is passed' do
      assert_difference "EmailAddress.count" do
        post :create, person: {first_name: 'funk',
                               email_addresses_attributes: [email: 'foo@example.com']},
                      secret: @client.secret
      end
    end

    should 'match an existing person when email address is a match' do
      person = Factory(:person)
      person.email_addresses.create(email: 'foo@example.com')
      assert_no_difference "Person.count" do
        post :create, person: {first_name: 'funk',
                               email_addresses_attributes: [email: 'foo@example.com']},
                      secret: @client.secret
      end

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

