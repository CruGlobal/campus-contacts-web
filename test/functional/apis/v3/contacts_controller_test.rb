require 'test_helper'

class Apis::V3::ContactAssignmentsControllerTest < ActionController::TestCase
  setup do
    request.env['HTTP_ACCEPT'] = 'application/json'
    @client = Factory(:client)
    @person = Factory(:user_no_org).person
    @org = @client.organization
    @org.add_admin(@person)
    @contact_assignment = Factory(:contact_assignment, organization: @org, assigned_to: @person)
  end

  context '.index' do

    should 'return a list of contact assignments' do
      get :index, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal 1, json['contact_assignments'].length, json.inspect
    end

    context 'filters' do

      should 'filter by assigned_to' do
        get :index, secret: @client.secret, filters: {assigned_to_id: @person.id}
        json = JSON.parse(response.body)
        assert_equal 1, json['contact_assignments'].length, json.inspect
      end

      should 'filter by ids' do
        # No matches
        get :index, secret: @client.secret, filters: {ids: '0'}
        json = JSON.parse(response.body)
        assert_equal 0, json['contact_assignments'].length, json.inspect

        # 1 contact_assignment
        get :index, secret: @client.secret, filters: {ids: @contact_assignment.id.to_s}
        json = JSON.parse(response.body)
        assert_equal 1, json['contact_assignments'].length, json.inspect

      end

      should 'filter by contact_assignment_id' do
        # No matches
        get :index, secret: @client.secret, filters: {person_id: '0'}
        json = JSON.parse(response.body)
        assert_equal 0, json['contact_assignments'].length, json.inspect

        # 1 contact_assignment
        get :index, secret: @client.secret, filters: {person_id: @contact_assignment.person_id.to_s}
        json = JSON.parse(response.body)
        assert_equal 1, json['contact_assignments'].length, json.inspect

      end

    end
  end


  context '.show' do
    should 'return a contact_assignment' do
      get :show, id: @contact_assignment.id, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal @contact_assignment.id, json['contact_assignment']['id']
    end
  end

  context '.create' do
    should 'create and return a contact_assignment' do
      assert_difference "Person.count" do
        post :create, contact_assignment: {person_id: Factory(:person).id, assigned_to_id: @person.id}, secret: @client.secret
      end
      json = JSON.parse(response.body)
      assert_equal @person.id, json['contact_assignment']['assigned_to_id']
    end

  end

  context '.update' do
    should 'create and return a contact_assignment' do
      put :update, id: @contact_assignment.id, contact_assignment: {assigned_to_id: '5'}, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal 5, json['contact_assignment']['assigned_to_id']
    end
  end

  context '.destroy' do
    should 'create and return a contact_assignment' do
      delete :destroy, id: @contact_assignment.id, secret: @client.secret
      assert_equal [], @org.contact_assignments
    end
  end



end

