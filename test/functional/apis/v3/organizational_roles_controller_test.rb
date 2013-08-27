require 'test_helper'

class Apis::V3::OrganizationalRolesControllerTest < ActionController::TestCase
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
      get :bulk, filters: {ids: "#{@person1.id},#{@person2.id}"}, add_roles: "#{@permission1.id}", remove_roles: "#{@permission_contact.id}", secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['organizational_roles'].count, json.inspect
      assert_equal @permission1.id, @person1.permissions.first.id
      assert_equal @permission1.id, @person2.permissions.first.id
      assert !@person1.permissions.include?(@permission_contact), @person1.permissions.inspect
      assert !@person2.permissions.include?(@permission_contact), @person2.permissions.inspect
    end

    should 'create and destroy bulk organizational_labels' do
      get :bulk, filters: {ids: "#{@person1.id},#{@person2.id}"}, add_roles: "#{@label1.id}", remove_roles: "#{@label.id}", secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['organizational_roles'].count, json.inspect
      assert @person1.labels.include?(@label1), @person1.labels.inspect
      assert @person2.labels.include?(@label1), @person2.labels.inspect
      assert !@person1.labels.include?(@label), @person1.labels.inspect
      assert !@person2.labels.include?(@label), @person2.labels.inspect
    end
  end

  context '.bulk_create' do
    setup do
      @contact1 = Factory(:person)
      @org.add_contact(@contact1)
      @contact2 = Factory(:person)
      @org.add_contact(@contact2)
      @admin_permission = Permission.find_by_i18n("admin")
    end
    should 'create bulk organizational_permissions' do
      EmailAddress.create(person_id: @contact1.id, email: "contact1email@x.com")
      EmailAddress.create(person_id: @contact2.id, email: "contact2email@x.com")
      get :bulk_create, filters: {ids: "#{@contact1.id},#{@contact2.id}"}, roles: "#{@admin_permission.id}", secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['organizational_roles'].count, json.inspect
      assert_equal @admin_permission.id, @contact1.permissions.first.id
      assert_equal @admin_permission.id, @contact2.permissions.first.id
    end

    should 'create bulk organizational_labels' do
      get :bulk_create, filters: {ids: "#{@person.id},#{@contact1.id},#{@contact2.id}"}, roles: "#{@label.id}", secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 3, json['organizational_roles'].count, json.inspect
      assert @person.labels.include?(@label)
      assert @contact1.labels.include?(@label)
      assert @contact2.labels.include?(@label)
    end

    should 'create bulk organizational_permissions and organizational_labels' do
      EmailAddress.create(person_id: @contact1.id, email: "contact1email@x.com")
      EmailAddress.create(person_id: @contact2.id, email: "contact2email@x.com")
      get :bulk_create, filters: {ids: "#{@contact1.id},#{@contact2.id}"}, roles: "#{@label.id},#{@admin_permission.id}", secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['organizational_roles'].count, json.inspect
      assert_equal @admin_permission.id, @contact1.permissions.first.id
      assert_equal @admin_permission.id, @contact2.permissions.first.id
      assert @contact1.labels.include?(@label)
      assert @contact2.labels.include?(@label)
    end
  end


  context '.bulk_destroy' do
    should 'destroy bulk organizational_permissions' do
      get :bulk_destroy, filters: {ids: "#{@person1.id},#{@person2.id}"}, roles: "#{@permission1.id}", secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['organizational_roles'].count, json.inspect
      assert !@person1.permissions.include?(@permission1), @person1.permissions.inspect
      assert !@person2.permissions.include?(@permission1), @person2.permissions.inspect
    end

    should 'destroy bulk organizational_labels' do
      Factory(:organizational_label, organization: @org, person: @person1, label: @label)
      Factory(:organizational_label, organization: @org, person: @person2, label: @label)
      assert @person1.labels.include?(@label)
      assert @person2.labels.include?(@label)

      get :bulk_destroy, filters: {ids: "#{@person1.id},#{@person2.id}"}, roles: "#{@label.id}", secret: @client.secret
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['organizational_roles'].count, json.inspect
      assert !@person1.labels.include?(@label), @person1.labels.inspect
      assert !@person2.labels.include?(@label), @person2.labels.inspect
    end

    should 'destroy bulk organizational_permissions and organizational_labels' do
      get :bulk_destroy, filters: {ids: "#{@person1.id},#{@person2.id}"}, roles: "#{@label.id},#{@permission1.id}", secret: @client.secret, order: 'created_at'
      assert_response :success
      json = JSON.parse(response.body)
      assert_equal 2, json['organizational_roles'].count, json.inspect
      assert !@person1.labels.include?(@label), @person1.labels.inspect
      assert !@person2.labels.include?(@label), @person2.labels.inspect
      assert !@person1.permissions.include?(@permission1), @person1.permissions.inspect
      assert !@person2.permissions.include?(@permission1), @person2.permissions.inspect
    end
  end
end

