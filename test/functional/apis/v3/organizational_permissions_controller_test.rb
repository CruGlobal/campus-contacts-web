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
    @org_permission = @org.organizational_permissions.last
    @permission_contact = @person2.permission_for_org_id(@org.id)
    @label1 = Factory(:label, organization: @org)
  end

  context '.index' do
    should "return a list of organization's organizational_permissions" do
      get :index, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal @org.organizational_permissions.count, json['organizational_permissions'].count, json.inspect
    end
  end

  context '.show' do
    should 'return an organizational_permission' do
      get :show, id: @org_permission.id, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal @org_permission.id, json['organizational_permission']['id'], json.inspect
    end
  end

  context '.create' do
    should 'create and return an organizational_permission' do
      @person3 = Factory(:person)
      assert_difference "OrganizationalPermission.count" do
        post :create, organizational_permission: {permission_id: @permission_contact.id, person_id: @person3.id}, secret: @client.secret
      end
      json = JSON.parse(response.body)
      assert_equal @person3.id, json['organizational_permission']['person_id'], json.inspect
    end
  end

  context '.update' do
    should 'create and return an organizational_permission' do
      put :update, id: @org_permission.id, organizational_permission: {archive_date: '2013-01-01'}, secret: @client.secret
      json = JSON.parse(response.body)
      assert_equal '2013-01-01'.to_date, json['organizational_permission']['archive_date'].to_date, json.inspect
    end
  end

  context '.destroy' do
    should 'create and return an organizational_permission' do
      delete :destroy, id: @org_permission.id, secret: @client.secret
      @org_permission.reload
      assert_not_nil @org_permission.archive_date, @org_permission.inspect
    end
  end



  context '.bulk' do
    setup do
      @contact1 = Factory(:person)
      @org.add_contact(@contact1)
      @contact2 = Factory(:person)
      @org.add_contact(@contact2)
      @admin_permission = Permission.find_by_i18n("admin")
    end
    should 'create and destroy bulk organizational_permissions' do
      get :bulk, filters: {ids: "#{@contact1.id},#{@contact2.id}"}, add_permission: "#{@admin_permission.id}", remove_permission: "#{@permission_contact.id}", secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['people'].count, json.inspect
      assert_equal @admin_permission.id, @contact1.permissions.first.id
      assert_equal @admin_permission.id, @contact2.permissions.first.id
      assert !@contact1.permissions.include?(@permission_contact), @contact1.permissions.inspect
      assert !@contact2.permissions.include?(@permission_contact), @contact2.permissions.inspect
    end
  end

  context '.bulk_create' do
    setup do
      @contact1 = Factory(:person)
      @contact2 = Factory(:person)
      @admin_permission = Permission.find_by_i18n("admin")
      @user_permission = Permission.find_by_i18n("user")
      @contact_permission = Permission.find_by_i18n("no_permissions")
    end
    should 'replace contact to admin permissions' do
      @org.add_permission_to_person(@contact1, @contact_permission.id)
      @org.add_permission_to_person(@contact2, @contact_permission.id)
      get :bulk_create, filters: {ids: "#{@contact1.id},#{@contact2.id}"}, permission: "#{@admin_permission.id}", secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['people'].count, json.inspect
      assert_equal @admin_permission.id, @contact1.permissions.first.id
      assert_equal @admin_permission.id, @contact2.permissions.first.id
    end
    should 'replace contact to leader permissions' do
      @org.add_permission_to_person(@contact1, @contact_permission.id)
      @org.add_permission_to_person(@contact2, @contact_permission.id)
      get :bulk_create, filters: {ids: "#{@contact1.id},#{@contact2.id}"}, permission: "#{@user_permission.id}", secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['people'].count, json.inspect
      assert_equal @user_permission.id, @contact1.permissions.first.id
      assert_equal @user_permission.id, @contact2.permissions.first.id
    end
    should 'replace leader to admin permissions' do
      @org.add_permission_to_person(@contact1, @user_permission.id)
      @org.add_permission_to_person(@contact2, @user_permission.id)
      get :bulk_create, filters: {ids: "#{@contact1.id},#{@contact2.id}"}, permission: "#{@admin_permission.id}", secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['people'].count, json.inspect
      assert_equal @admin_permission.id, @contact1.permissions.first.id
      assert_equal @admin_permission.id, @contact2.permissions.first.id
    end
    should 'ignore contact over admin permissions' do
      @org.add_permission_to_person(@contact1, @admin_permission.id)
      @org.add_permission_to_person(@contact2, @admin_permission.id)
      get :bulk_create, filters: {ids: "#{@contact1.id},#{@contact2.id}"}, permission: "#{@contact_permission.id}", secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['people'].count, json.inspect
      assert_equal @admin_permission.id, @contact1.permissions.first.id
      assert_equal @admin_permission.id, @contact2.permissions.first.id
    end
    should 'ignore leader over admin permissions' do
      @org.add_permission_to_person(@contact1, @admin_permission.id)
      @org.add_permission_to_person(@contact2, @admin_permission.id)
      get :bulk_create, filters: {ids: "#{@contact1.id},#{@contact2.id}"}, permission: "#{@user_permission.id}", secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['people'].count, json.inspect
      assert_equal @admin_permission.id, @contact1.permissions.first.id
      assert_equal @admin_permission.id, @contact2.permissions.first.id
    end
    should 'ignore contact over leader permissions' do
      @org.add_permission_to_person(@contact1, @user_permission.id)
      @org.add_permission_to_person(@contact2, @user_permission.id)
      get :bulk_create, filters: {ids: "#{@contact1.id},#{@contact2.id}"}, permission: "#{@contact_permission.id}", secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['people'].count, json.inspect
      assert_equal @user_permission.id, @contact1.permissions.first.id
      assert_equal @user_permission.id, @contact2.permissions.first.id
    end
  end


  context '.bulk_destroy' do
    should 'destroy bulk organizational_permissions' do
      get :bulk_destroy, filters: {ids: "#{@person1.id},#{@person2.id}"}, permission: "#{@permission1.id}", secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['people'].count, json.inspect
      assert !@person1.permissions.include?(@permission1), @person1.permissions.inspect
      assert !@person2.permissions.include?(@permission1), @person2.permissions.inspect
    end
  end


  context '.bulk_archive' do
    should 'archive bulk organizational_permissions' do
      get :bulk_archive, filters: {ids: "#{@person1.id},#{@person2.id}"}, permission: "#{@permission1.id}", secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['people'].count, json.inspect
      assert !@person1.permissions.include?(@permission1), @person1.permissions.inspect
      assert !@person2.permissions.include?(@permission1), @person2.permissions.inspect
    end
  end

end

