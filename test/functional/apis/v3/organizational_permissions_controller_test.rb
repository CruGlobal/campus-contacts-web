require 'test_helper'

class Apis::V3::OrganizationalPermissionsControllerTest < ActionController::TestCase
  setup do
    request.env['HTTP_ACCEPT'] = 'application/json'
    @client = Factory(:client)
    @user = Factory(:user_no_org)
    @person = @user.person
    @org = @client.organization

    @org.add_admin(@person)

    @permission = @user.person.permission_for_org_id(@org.id)
    @permission1 = Factory(:permission)
    @label = Factory(:label, organization: @org)

    Factory(:organizational_label, organization: @org, person: @person, label: @label)

    @person1 = Factory(:person)
    @org.add_contact(@person1)
    @person2 = Factory(:person)
    @org.add_contact(@person2)
    @permission_contact = @person2.permission_for_org_id(@org.id)
    @label1 = Factory(:label, organization: @org)
  end



  context '.bulk' do
    should 'create and destroy bulk organizational_permissions' do
      get :bulk, filters: {ids: "#{@person1.id},#{@person2.id}"}, add_permission: "#{@permission1.id}", remove_permission: "#{@permission_contact.id}", secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['organizational_permissions'].count, json.inspect
      assert_equal @permission1.id, @person1.permissions.first.id
      assert_equal @permission1.id, @person2.permissions.first.id
      assert !@person1.permissions.include?(@permission_contact), @person1.permissions.inspect
      assert !@person2.permissions.include?(@permission_contact), @person2.permissions.inspect
    end
  end

  context '.bulk_create' do
    should 'create bulk organizational_permissions' do
      get :bulk_create, filters: {ids: "#{@person1.id},#{@person2.id}"}, permission: "#{@permission1.id}", secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['organizational_permissions'].count, json.inspect
      assert_equal @permission1.id, @person1.permissions.first.id
      assert_equal @permission1.id, @person2.permissions.first.id
    end
  end


  context '.bulk_destroy' do
    should 'destroy bulk organizational_permissions' do
      get :bulk_destroy, filters: {ids: "#{@person1.id},#{@person2.id}"}, permission: "#{@permission1.id}", secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['organizational_permissions'].count, json.inspect
      assert !@person1.permissions.include?(@permission1), @person1.permissions.inspect
      assert !@person2.permissions.include?(@permission1), @person2.permissions.inspect
    end
  end

end

