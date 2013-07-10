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

    context 'filters' do
      setup do
        # Add a second person
        @person2 = Factory(:person, first_name: 'Bob', last_name: 'Jones')
        @client.organization.add_contact(@person2)
      end

      context 'filter by permission' do
        should 'return no results for a permission no one has' do
          get :index, secret: @client.secret, filters: {permissions: '-1'}, include: :organizational_permissions
          json = JSON.parse(response.body)
          assert_equal 0, json['people'].length, json.inspect
        end

        should 'return results for a permission someone has' do
          get :index, secret: @client.secret, filters: {permissions: Permission::ADMIN_ID}
          json = JSON.parse(response.body)
          assert_equal 1, json['people'].length, json.inspect
        end

        should 'include archived permissions when requested' do
          @person2.organizational_permissions.create!(organization: @client.organization, permission_id: Permission::ADMIN_ID, archive_date: Date.today)
          get :index, secret: @client.secret, filters: {permissions: Permission::ADMIN_ID}, include_archived: 'true'
          json = JSON.parse(response.body)
          assert_equal 2, json['people'].length, json.inspect
        end

      end

      should 'filter by first name with no matches' do
        # No matches
        get :index, secret: @client.secret, filters: {first_name_like: 'zzzzzzzzzz'}
        json = JSON.parse(response.body)
        assert_equal 0, json['people'].length, json.inspect
      end

      should 'filter by first name with a match' do
        # 1 person
        get :index, secret: @client.secret, filters: {first_name_like: @person.first_name[0..1]}
        json = JSON.parse(response.body)
        assert_equal 1, json['people'].length, json.inspect
      end

      should 'filter by last name with no matches' do
        # No matches
        get :index, secret: @client.secret, filters: {last_name_like: 'zzzzzzzzzz'}
        json = JSON.parse(response.body)
        assert_equal 0, json['people'].length, json.inspect
      end

      should 'filter by last name with a match' do
        # 1 person
        get :index, secret: @client.secret, filters: {last_name_like: @person.last_name[0..1]}
        json = JSON.parse(response.body)
        assert_equal 1, json['people'].length, json.inspect
      end

      should 'filter by followup status with no matches' do
        # No matches
        get :index, secret: @client.secret, filters: {followup_status: 'zzzzzzzzzz'}
        json = JSON.parse(response.body)
        assert_equal 0, json['people'].length, json.inspect
      end

      should 'filter by followup status with a match' do
        @person.organizational_permissions.create(organization: @client.organization,
                                            followup_status: 'contacted')

        # 1 person
        get :index, secret: @client.secret, filters: {followup_status: 'contacted'}
        json = JSON.parse(response.body)
        assert_equal 1, json['people'].length, json.inspect

      end

      should 'filter by contact assignment' do
        Factory(:contact_assignment, organization: @client.organization,
                                      assigned_to: @person2,
                                      person: @person)

        # 1 person
        get :index, secret: @client.secret, filters: {assigned_to: @person2.id.to_s}
        json = JSON.parse(response.body)
        assert_equal 1, json['people'].length, json.inspect

      end

      should 'filter by contact assignment and followup_status' do
        Factory(:contact_assignment, organization: @client.organization,
                                      assigned_to: @person2,
                                      person: @person)
        @person.organizational_permissions.first.update_attributes(followup_status: 'contacted')

        # 1 person
        get :index, secret: @client.secret, filters: {assigned_to: @person2.id.to_s, followup_status: 'contacted'}
        json = JSON.parse(response.body)
        assert_equal 1, json['people'].length, json.inspect

      end


      context 'filtering by name_or_email_like' do

        should 'match first name' do
          get :index, secret: @client.secret, filters: {name_or_email_like: @person.first_name[0..2]}
          json = JSON.parse(response.body)
          assert_equal 1, json['people'].length, json.inspect
        end

        should 'match email address' do
          @person2.email_addresses.create(email: 'foo@example.com')
          get :index, secret: @client.secret, filters: {name_or_email_like: 'foo@'}
          json = JSON.parse(response.body)
          assert_equal 1, json['people'].length, json.inspect
        end

        should 'match name' do
          @person2.email_addresses.create(email: 'foo@example.com')
          get :index, secret: @client.secret, filters: {name_or_email_like: [@person.first_name, @person.last_name].join(' ')}
          json = JSON.parse(response.body)
          assert_equal 1, json['people'].length, json.inspect
        end
      end

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
                               email_addresses_attributes: [{email: 'foo@example.com'}]},
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
      assert_equal [], assigns(:person).organizational_permissions
    end
  end



end

