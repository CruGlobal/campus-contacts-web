require 'test_helper'

class Apis::V3::OrganizationalPermissionsControllerTest < ActionController::TestCase
  setup do
    request.env["HTTP_ACCEPT"] = "application/json"
    @org = Factory(:organization)
    @client = Factory(:client, organization: @org)

    # Admin
    @user1 = Factory(:user_api)
    @person1 = @user1.person
    @org.add_admin(@person1)
    @admin_permission = @person1.permission_for_org_id(@org.id)
    @admin_token = Factory(:access_token, identity: @user1.id, client_id: @client.id)

    # User
    @user2 = Factory(:user_api)
    @person2 = @user2.person
    @org.add_user(@person2)
    @user_permission = @person2.permission_for_org_id(@org.id)
    @user_token = Factory(:access_token, identity: @user2.id, client_id: @client.id)

    # No Permission
    @user3 = Factory(:user_api)
    @person3 = @user3.person
    @org.add_contact(@person3)
    @contact_permission = @person3.permission_for_org_id(@org.id)
    @no_permission_token = Factory(:access_token, identity: @user3.id, client_id: @client.id)

    # Other
    @person = Factory(:person)
    Factory(:email_address, person: @person)
    @org.add_contact(@person)
    @org_permission = @org.organizational_permissions.last
    @another_person = Factory(:person)
    Factory(:email_address, person: @another_person)
    @org.add_contact(@another_person)
    @another_org_permission = @org.organizational_permissions.last

    @no_org_person = Factory(:person)
    Factory(:email_address, person: @no_org_person)
    @no_org_person_org_permission = @org.organizational_permissions.last
    @another_no_org_person = Factory(:person)
    Factory(:email_address, person: @another_no_org_person)
    @another_no_org_person_org_permission = @org.organizational_permissions.last
  end

  context ".index" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "return a list of organizational_permissions" do
        get :index, access_token: @token
        json = JSON.parse(response.body)
        assert_equal @org.organizational_permissions.count, json["organizational_permissions"].count, json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "return a list of organizational_permissions" do
        get :index, access_token: @token
        json = JSON.parse(response.body)
        assert_equal @org.organizational_permissions.count, json["organizational_permissions"].count, json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not return a list of organizational_permissions" do
        get :index, access_token: @token
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

  context ".show" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "return an organizational_permission" do
        get :show, access_token: @token, id: @org_permission.id
        json = JSON.parse(response.body)
        assert_equal @org_permission.id, json["organizational_permission"]["id"], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "return an organizational_permission" do
        get :show, access_token: @token, id: @org_permission.id
        json = JSON.parse(response.body)
        assert_equal @org_permission.id, json["organizational_permission"]["id"], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not return an organizational_permission" do
        get :show, access_token: @token, id: @org_permission.id
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

  context ".create" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "create and return an ADMIN organizational_permission" do
        assert_difference "OrganizationalPermission.count", 1 do
          post :create, access_token: @token,
                organizational_permission: {permission_id: @admin_permission.id, person_id: @no_org_person.id}
        end
        json = JSON.parse(response.body)
        assert_equal @no_org_person.id, json['organizational_permission']['person_id'], json.inspect
        assert_equal @admin_permission.id, json['organizational_permission']['permission_id'], json.inspect
      end
      should "create and return an USER organizational_permission" do
        assert_difference "OrganizationalPermission.count", 1 do
          post :create, access_token: @token,
                organizational_permission: {permission_id: @user_permission.id, person_id: @no_org_person.id}
        end
        json = JSON.parse(response.body)
        assert_equal @no_org_person.id, json['organizational_permission']['person_id'], json.inspect
        assert_equal @user_permission.id, json['organizational_permission']['permission_id'], json.inspect
      end
      should "create and return an CONTACT organizational_permission" do
        assert_difference "OrganizationalPermission.count", 1 do
          post :create, access_token: @token,
                organizational_permission: {permission_id: @contact_permission.id, person_id: @no_org_person.id}
        end
        json = JSON.parse(response.body)
        assert_equal @no_org_person.id, json['organizational_permission']['person_id'], json.inspect
        assert_equal @contact_permission.id, json['organizational_permission']['permission_id'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "not create and return an ADMIN organizational_permission" do
        assert_difference "OrganizationalPermission.count", 0 do
          post :create, access_token: @token,
                organizational_permission: {permission_id: @admin_permission.id, person_id: @no_org_person.id}
        end
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
      should "create and return an USER organizational_permission" do
        assert_difference "OrganizationalPermission.count", 1 do
          post :create, access_token: @token,
                organizational_permission: {permission_id: @user_permission.id, person_id: @no_org_person.id}
        end
        json = JSON.parse(response.body)
        assert_equal @no_org_person.id, json['organizational_permission']['person_id'], json.inspect
        assert_equal @user_permission.id, json['organizational_permission']['permission_id'], json.inspect
      end
      should "create and return an CONTACT organizational_permission" do
        assert_difference "OrganizationalPermission.count", 1 do
          post :create, access_token: @token,
                organizational_permission: {permission_id: @contact_permission.id, person_id: @no_org_person.id}
        end
        json = JSON.parse(response.body)
        assert_equal @no_org_person.id, json['organizational_permission']['person_id'], json.inspect
        assert_equal @contact_permission.id, json['organizational_permission']['permission_id'], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not create and return an ADMIN organizational_permission" do
        assert_difference "OrganizationalPermission.count", 0 do
          post :create, access_token: @token,
                organizational_permission: {permission_id: @admin_permission.id, person_id: @no_org_person.id}
        end
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
      should "not create and return an USER organizational_permission" do
        assert_difference "OrganizationalPermission.count", 0 do
          post :create, access_token: @token,
                organizational_permission: {permission_id: @user_permission.id, person_id: @no_org_person.id}
        end
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
      should "not create and return an CONTACT organizational_permission" do
        assert_difference "OrganizationalPermission.count", 0 do
          post :create, access_token: @token,
                organizational_permission: {permission_id: @contact_permission.id, person_id: @no_org_person.id}
        end
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

  context ".update" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "update and return an ADMIN organizational_permission" do
        @org_permission.update_attributes(permission_id: @admin_permission.id)
        put :update, access_token: @token,
            id: @org_permission.id, organizational_permission: {archive_date: '2013-01-01'}
        json = JSON.parse(response.body)
        assert_equal '2013-01-01'.to_date, json['organizational_permission']['archive_date'].to_date, json.inspect
        assert_equal @admin_permission.id, json['organizational_permission']['permission_id'], json.inspect
      end
      should "update and return an USER organizational_permission" do
        @org_permission.update_attributes(permission_id: @user_permission.id)
        put :update, access_token: @token,
            id: @org_permission.id, organizational_permission: {archive_date: '2013-01-01'}
        json = JSON.parse(response.body)
        assert_equal '2013-01-01'.to_date, json['organizational_permission']['archive_date'].to_date, json.inspect
        assert_equal @user_permission.id, json['organizational_permission']['permission_id'], json.inspect
      end
      should "update and return an CONTACT organizational_permission" do
        @org_permission.update_attributes(permission_id: @contact_permission.id)
        put :update, access_token: @token,
            id: @org_permission.id, organizational_permission: {archive_date: '2013-01-01'}
        json = JSON.parse(response.body)
        assert_equal '2013-01-01'.to_date, json['organizational_permission']['archive_date'].to_date, json.inspect
        assert_equal @contact_permission.id, json['organizational_permission']['permission_id'], json.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "not update and return an ADMIN organizational_permission" do
        @org_permission.update_attributes(permission_id: @admin_permission.id)
        put :update, access_token: @token,
            id: @org_permission.id, organizational_permission: {archive_date: '2013-01-01'}
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
      should "update and return an USER organizational_permission" do
        @org_permission.update_attributes(permission_id: @user_permission.id)
        put :update, access_token: @token,
            id: @org_permission.id, organizational_permission: {archive_date: '2013-01-01'}
        json = JSON.parse(response.body)
        assert_equal '2013-01-01'.to_date, json['organizational_permission']['archive_date'].to_date, json.inspect
        assert_equal @user_permission.id, json['organizational_permission']['permission_id'], json.inspect
      end
      should "update and return an CONTACT organizational_permission" do
        @org_permission.update_attributes(permission_id: @contact_permission.id)
        put :update, access_token: @token,
            id: @org_permission.id, organizational_permission: {archive_date: '2013-01-01'}
        json = JSON.parse(response.body)
        assert_equal '2013-01-01'.to_date, json['organizational_permission']['archive_date'].to_date, json.inspect
        assert_equal @contact_permission.id, json['organizational_permission']['permission_id'], json.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not update and return an ADMIN organizational_permission" do
        @org_permission.update_attributes(permission_id: @admin_permission.id)
        put :update, access_token: @token,
            id: @org_permission.id, organizational_permission: {archive_date: '2013-01-01'}
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
      should "update and return an USER organizational_permission" do
        @org_permission.update_attributes(permission_id: @user_permission.id)
        put :update, access_token: @token,
            id: @org_permission.id, organizational_permission: {archive_date: '2013-01-01'}
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
      should "update and return an CONTACT organizational_permission" do
        @org_permission.update_attributes(permission_id: @contact_permission.id)
        put :update, access_token: @token,
            id: @org_permission.id, organizational_permission: {archive_date: '2013-01-01'}
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

  context ".destroy" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "delete and return an ADMIN organizational_permission" do
        @org_permission.update_attributes(permission_id: @admin_permission.id)
        delete :destroy, access_token: @token, id: @org_permission.id
        @org_permission.reload
        assert_not_nil @org_permission.deleted_at, @org_permission.inspect
      end
      should "delete and return an USER organizational_permission" do
        @org_permission.update_attributes(permission_id: @user_permission.id)
        delete :destroy, access_token: @token, id: @org_permission.id
        @org_permission.reload
        assert_not_nil @org_permission.deleted_at, @org_permission.inspect
      end
      should "delete and return an CONTACT organizational_permission" do
        @org_permission.update_attributes(permission_id: @contact_permission.id)
        delete :destroy, access_token: @token, id: @org_permission.id
        @org_permission.reload
        assert_not_nil @org_permission.deleted_at, @org_permission.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "not delete and return an ADMIN organizational_permission" do
        @org_permission.update_attributes(permission_id: @admin_permission.id)
        delete :destroy, access_token: @token, id: @org_permission.id
        @org_permission.reload
        assert_nil @org_permission.deleted_at, @org_permission.inspect
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
      should "delete and return an USER organizational_permission" do
        @org_permission.update_attributes(permission_id: @user_permission.id)
        delete :destroy, access_token: @token, id: @org_permission.id
        @org_permission.reload
        assert_not_nil @org_permission.deleted_at, @org_permission.inspect
      end
      should "delete and return an CONTACT organizational_permission" do
        @org_permission.update_attributes(permission_id: @contact_permission.id)
        delete :destroy, access_token: @token, id: @org_permission.id
        @org_permission.reload
        assert_not_nil @org_permission.deleted_at, @org_permission.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not delete and return an ADMIN organizational_permission" do
        @org_permission.update_attributes(permission_id: @admin_permission.id)
        delete :destroy, access_token: @token, id: @org_permission.id
        @org_permission.reload
        assert_nil @org_permission.deleted_at, @org_permission.inspect
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
      should "not delete and return an USER organizational_permission" do
        @org_permission.update_attributes(permission_id: @user_permission.id)
        delete :destroy, access_token: @token, id: @org_permission.id
        @org_permission.reload
        assert_nil @org_permission.deleted_at, @org_permission.inspect
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
      should "not delete and return an CONTACT organizational_permission" do
        @org_permission.update_attributes(permission_id: @contact_permission.id)
        delete :destroy, access_token: @token, id: @org_permission.id
        @org_permission.reload
        assert_nil @org_permission.archive_date, @org_permission.inspect
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

  context ".archive" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should "archive and return an ADMIN organizational_permission" do
        @org_permission.update_attributes(permission_id: @admin_permission.id)
        post :archive, access_token: @token, id: @org_permission.id
        @org_permission.reload
        assert_not_nil @org_permission.archive_date, @org_permission.inspect
      end
      should "archive and return an USER organizational_permission" do
        @org_permission.update_attributes(permission_id: @user_permission.id)
        post :archive, access_token: @token, id: @org_permission.id
        @org_permission.reload
        assert_not_nil @org_permission.archive_date, @org_permission.inspect
      end
      should "archive and return an CONTACT organizational_permission" do
        @org_permission.update_attributes(permission_id: @contact_permission.id)
        post :archive, access_token: @token, id: @org_permission.id
        @org_permission.reload
        assert_not_nil @org_permission.archive_date, @org_permission.inspect
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should "not archive and return an ADMIN organizational_permission" do
        @org_permission.update_attributes(permission_id: @admin_permission.id)
        post :archive, access_token: @token, id: @org_permission.id
        @org_permission.reload
        assert_nil @org_permission.archive_date, @org_permission.inspect
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
      should "archive and return an USER organizational_permission" do
        @org_permission.update_attributes(permission_id: @user_permission.id)
        post :archive, access_token: @token, id: @org_permission.id
        @org_permission.reload
        assert_not_nil @org_permission.archive_date, @org_permission.inspect
      end
      should "archive and return an CONTACT organizational_permission" do
        @org_permission.update_attributes(permission_id: @contact_permission.id)
        post :archive, access_token: @token, id: @org_permission.id
        @org_permission.reload
        assert_not_nil @org_permission.archive_date, @org_permission.inspect
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should "not archive and return an ADMIN organizational_permission" do
        @org_permission.update_attributes(permission_id: @admin_permission.id)
        post :archive, access_token: @token, id: @org_permission.id
        @org_permission.reload
        assert_nil @org_permission.archive_date, @org_permission.inspect
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
      should "not archive and return an USER organizational_permission" do
        @org_permission.update_attributes(permission_id: @user_permission.id)
        post :archive, access_token: @token, id: @org_permission.id
        @org_permission.reload
        assert_nil @org_permission.archive_date, @org_permission.inspect
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
      should "not archive and return an CONTACT organizational_permission" do
        @org_permission.update_attributes(permission_id: @contact_permission.id)
        post :archive, access_token: @token, id: @org_permission.id
        @org_permission.reload
        assert_nil @org_permission.archive_date, @org_permission.inspect
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

  context ".bulk" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should 'create ADMIN and destroy CONTACT organizational_permissions' do
        get :bulk, access_token: @token,
          filters: {ids: "#{@person.id},#{@another_person.id}"}, add_permission: "#{@admin_permission.id}", remove_permission: "#{@contact_permission.id}"
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        assert @person.permissions_for_org_id(@org.id).include?(@admin_permission)
        assert @another_person.permissions_for_org_id(@org.id).include?(@admin_permission)
        assert !@person.permissions_for_org_id(@org.id).include?(@contact_permission)
        assert !@another_person.permissions_for_org_id(@org.id).include?(@contact_permission)
      end
      should 'create USER and destroy CONTACT organizational_permissions' do
        get :bulk, access_token: @token,
          filters: {ids: "#{@person.id},#{@another_person.id}"}, add_permission: "#{@user_permission.id}", remove_permission: "#{@contact_permission.id}"
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        assert @person.permissions_for_org_id(@org.id).include?(@user_permission)
        assert @another_person.permissions_for_org_id(@org.id).include?(@user_permission)
        assert !@person.permissions_for_org_id(@org.id).include?(@contact_permission)
        assert !@another_person.permissions_for_org_id(@org.id).include?(@contact_permission)
      end
      should 'create CONTACT and destroy USER organizational_permissions' do
        get :bulk, access_token: @token,
          filters: {ids: "#{@person.id},#{@another_person.id}"}, add_permission: "#{@contact_permission.id}", remove_permission: "#{@user_permission.id}"
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        assert @person.permissions_for_org_id(@org.id).include?(@contact_permission)
        assert @another_person.permissions_for_org_id(@org.id).include?(@contact_permission)
        assert !@person.permissions_for_org_id(@org.id).include?(@user_permission)
        assert !@another_person.permissions_for_org_id(@org.id).include?(@user_permission)
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should 'not create ADMIN and destroy CONTACT organizational_permissions' do
        get :bulk, access_token: @token,
          filters: {ids: "#{@person.id},#{@another_person.id}"}, add_permission: "#{@admin_permission.id}", remove_permission: "#{@contact_permission.id}"
        assert @person.permissions_for_org_id(@org.id).include?(@contact_permission)
        assert @another_person.permissions_for_org_id(@org.id).include?(@contact_permission)
        assert !@person.permissions_for_org_id(@org.id).include?(@admin_permission)
        assert !@another_person.permissions_for_org_id(@org.id).include?(@admin_permission)
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
      should 'create USER and destroy CONTACT organizational_permissions' do
        get :bulk, access_token: @token,
          filters: {ids: "#{@person.id},#{@another_person.id}"}, add_permission: "#{@user_permission.id}", remove_permission: "#{@contact_permission.id}"
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        assert @person.permissions_for_org_id(@org.id).include?(@user_permission)
        assert @another_person.permissions_for_org_id(@org.id).include?(@user_permission)
        assert !@person.permissions_for_org_id(@org.id).include?(@contact_permission)
        assert !@another_person.permissions_for_org_id(@org.id).include?(@contact_permission)
      end
      should 'create CONTACT and destroy USER organizational_permissions' do
        get :bulk, access_token: @token,
          filters: {ids: "#{@person.id},#{@another_person.id}"}, add_permission: "#{@contact_permission.id}", remove_permission: "#{@user_permission.id}"
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        assert @person.permissions_for_org_id(@org.id).include?(@contact_permission)
        assert @another_person.permissions_for_org_id(@org.id).include?(@contact_permission)
        assert !@person.permissions_for_org_id(@org.id).include?(@user_permission)
        assert !@another_person.permissions_for_org_id(@org.id).include?(@user_permission)
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should 'not create ADMIN and destroy CONTACT organizational_permissions' do
        get :bulk, access_token: @token,
          filters: {ids: "#{@person.id},#{@another_person.id}"}, add_permission: "#{@admin_permission.id}", remove_permission: "#{@contact_permission.id}"
        assert @person.permissions_for_org_id(@org.id).include?(@contact_permission)
        assert @another_person.permissions_for_org_id(@org.id).include?(@contact_permission)
        assert !@person.permissions_for_org_id(@org.id).include?(@admin_permission)
        assert !@another_person.permissions_for_org_id(@org.id).include?(@admin_permission)
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
      should 'not create USER and destroy CONTACT organizational_permissions' do
        get :bulk, access_token: @token,
          filters: {ids: "#{@person.id},#{@another_person.id}"}, add_permission: "#{@user_permission.id}", remove_permission: "#{@contact_permission.id}"
        assert @person.permissions_for_org_id(@org.id).include?(@contact_permission)
        assert @another_person.permissions_for_org_id(@org.id).include?(@contact_permission)
        assert !@person.permissions_for_org_id(@org.id).include?(@user_permission)
        assert !@another_person.permissions_for_org_id(@org.id).include?(@user_permission)
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
      should 'not create CONTACT and destroy USER organizational_permissions' do
        @org_permission.update_attributes(permission_id: @user_permission.id)
        @another_org_permission.update_attributes(permission_id: @user_permission.id)
        get :bulk, access_token: @token,
          filters: {ids: "#{@person.id},#{@another_person.id}"}, add_permission: "#{@contact_permission.id}", remove_permission: "#{@user_permission.id}"
        assert @person.permissions_for_org_id(@org.id).include?(@user_permission)
        assert @another_person.permissions_for_org_id(@org.id).include?(@user_permission)
        assert !@person.permissions_for_org_id(@org.id).include?(@contact_permission)
        assert !@another_person.permissions_for_org_id(@org.id).include?(@contact_permission)
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

  context ".bulk_create" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should 'bulk create ADMIN organizational_permissions' do
        post :bulk_create, access_token: @token,
              filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@admin_permission.id}"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        assert @person.permissions_for_org_id(@org.id).include?(@admin_permission)
        assert @another_person.permissions_for_org_id(@org.id).include?(@admin_permission)
      end
      should 'bulk create USER organizational_permissions' do
        post :bulk_create, access_token: @token,
              filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@user_permission.id}"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        assert @person.permissions_for_org_id(@org.id).include?(@user_permission)
        assert @another_person.permissions_for_org_id(@org.id).include?(@user_permission)
      end
      should 'bulk create CONTACT organizational_permissions' do
        post :bulk_create, access_token: @token,
              filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@contact_permission.id}"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        assert @person.permissions_for_org_id(@org.id).include?(@contact_permission)
        assert @another_person.permissions_for_org_id(@org.id).include?(@contact_permission)
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should 'not bulk create ADMIN organizational_permissions' do
        post :bulk_create, access_token: @token,
              filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@admin_permission.id}"
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
      should 'bulk create USER organizational_permissions' do
        post :bulk_create, access_token: @token,
              filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@user_permission.id}"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        assert @person.permissions_for_org_id(@org.id).include?(@user_permission)
        assert @another_person.permissions_for_org_id(@org.id).include?(@user_permission)
      end
      should 'bulk create CONTACT organizational_permissions' do
        post :bulk_create, access_token: @token,
              filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@contact_permission.id}"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        assert @person.permissions_for_org_id(@org.id).include?(@contact_permission)
        assert @another_person.permissions_for_org_id(@org.id).include?(@contact_permission)
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should 'not bulk create ADMIN organizational_permissions' do
        post :bulk_create, access_token: @token,
              filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@admin_permission.id}"
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
      should 'bulk create USER organizational_permissions' do
        post :bulk_create, access_token: @token,
              filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@user_permission.id}"
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
      should 'bulk create CONTACT organizational_permissions' do
        post :bulk_create, access_token: @token,
              filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@contact_permission.id}"
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
      end
    end
  end

  context ".bulk_destroy" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should 'bulk destroy ADMIN organizational_permissions' do
        @org_permission.update_attributes(permission_id: @admin_permission.id)
        @another_org_permission.update_attributes(permission_id: @admin_permission.id)
        delete :bulk_destroy, access_token: @token,
                filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@admin_permission.id}"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        @org_permission.reload
        @another_org_permission.reload
        assert_not_nil @org_permission.deleted_at, @org_permission.deleted_at
        assert_not_nil @another_org_permission.deleted_at, @another_org_permission.deleted_at
      end
      should 'bulk destroy USER organizational_permissions' do
        @org_permission.update_attributes(permission_id: @user_permission.id)
        @another_org_permission.update_attributes(permission_id: @user_permission.id)
        delete :bulk_destroy, access_token: @token,
                filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@user_permission.id}"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        @org_permission.reload
        @another_org_permission.reload
        assert_not_nil @org_permission.deleted_at, @org_permission.deleted_at
        assert_not_nil @another_org_permission.deleted_at, @another_org_permission.deleted_at
      end
      should 'bulk destroy CONTACT organizational_permissions' do
        @org_permission.update_attributes(permission_id: @contact_permission.id)
        @another_org_permission.update_attributes(permission_id: @contact_permission.id)
        delete :bulk_destroy, access_token: @token,
                filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@contact_permission.id}"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        @org_permission.reload
        @another_org_permission.reload
        assert_not_nil @org_permission.deleted_at, @org_permission.deleted_at
        assert_not_nil @another_org_permission.deleted_at, @another_org_permission.deleted_at
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should 'not bulk destroy ADMIN organizational_permissions' do
        @org_permission.update_attributes(permission_id: @admin_permission.id)
        @another_org_permission.update_attributes(permission_id: @admin_permission.id)
        delete :bulk_destroy, access_token: @token,
                filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@admin_permission.id}"
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        @org_permission.reload
        @another_org_permission.reload
        assert_nil @org_permission.deleted_at, @org_permission.deleted_at
        assert_nil @another_org_permission.deleted_at, @another_org_permission.deleted_at
      end
      should 'bulk destroy USER organizational_permissions' do
        @org_permission.update_attributes(permission_id: @user_permission.id)
        @another_org_permission.update_attributes(permission_id: @user_permission.id)
        delete :bulk_destroy, access_token: @token,
                filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@user_permission.id}"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        @org_permission.reload
        @another_org_permission.reload
        assert_not_nil @org_permission.deleted_at, @org_permission.deleted_at
        assert_not_nil @another_org_permission.deleted_at, @another_org_permission.deleted_at
      end
      should 'bulk destroy CONTACT organizational_permissions' do
        @org_permission.update_attributes(permission_id: @contact_permission.id)
        @another_org_permission.update_attributes(permission_id: @contact_permission.id)
        delete :bulk_destroy, access_token: @token,
                filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@contact_permission.id}"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        @org_permission.reload
        @another_org_permission.reload
        assert_not_nil @org_permission.deleted_at, @org_permission.deleted_at
        assert_not_nil @another_org_permission.deleted_at, @another_org_permission.deleted_at
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should 'not bulk destroy ADMIN organizational_permissions' do
        @org_permission.update_attributes(permission_id: @admin_permission.id)
        @another_org_permission.update_attributes(permission_id: @admin_permission.id)
        delete :bulk_destroy, access_token: @token,
                filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@admin_permission.id}"
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        @org_permission.reload
        @another_org_permission.reload
        assert_nil @org_permission.deleted_at, @org_permission.deleted_at
        assert_nil @another_org_permission.deleted_at, @another_org_permission.deleted_at
      end
      should 'not bulk destroy USER organizational_permissions' do
        @org_permission.update_attributes(permission_id: @user_permission.id)
        @another_org_permission.update_attributes(permission_id: @user_permission.id)
        delete :bulk_destroy, access_token: @token,
                filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@user_permission.id}"
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        @org_permission.reload
        @another_org_permission.reload
        assert_nil @org_permission.deleted_at, @org_permission.deleted_at
        assert_nil @another_org_permission.deleted_at, @another_org_permission.deleted_at
      end
      should 'not bulk destroy CONTACT organizational_permissions' do
        @org_permission.update_attributes(permission_id: @contact_permission.id)
        @another_org_permission.update_attributes(permission_id: @contact_permission.id)
        delete :bulk_destroy, access_token: @token,
                filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@contact_permission.id}"
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        @org_permission.reload
        @another_org_permission.reload
        assert_nil @org_permission.deleted_at, @org_permission.deleted_at
        assert_nil @another_org_permission.deleted_at, @another_org_permission.deleted_at
      end
    end
  end


  context ".bulk_archive" do
    context "ADMIN request" do
      setup do
        @token = @admin_token.code
      end
      should 'bulk archive ADMIN organizational_permissions' do
        @org_permission.update_attributes(permission_id: @admin_permission.id)
        @another_org_permission.update_attributes(permission_id: @admin_permission.id)
        post :bulk_archive, access_token: @token,
                filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@admin_permission.id}"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        @org_permission.reload
        @another_org_permission.reload
        assert_not_nil @org_permission.archive_date, @org_permission.archive_date
        assert_not_nil @another_org_permission.archive_date, @another_org_permission.archive_date
      end
      should 'bulk archive USER organizational_permissions' do
        @org_permission.update_attributes(permission_id: @user_permission.id)
        @another_org_permission.update_attributes(permission_id: @user_permission.id)
        post :bulk_archive, access_token: @token,
              filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@user_permission.id}"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        @org_permission.reload
        @another_org_permission.reload
        assert_not_nil @org_permission.archive_date, @org_permission.archive_date
        assert_not_nil @another_org_permission.archive_date, @another_org_permission.archive_date
      end
      should 'bulk archive CONTACT organizational_permissions' do
        @org_permission.update_attributes(permission_id: @contact_permission.id)
        @another_org_permission.update_attributes(permission_id: @contact_permission.id)
        post :bulk_archive, access_token: @token,
              filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@contact_permission.id}"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        @org_permission.reload
        @another_org_permission.reload
        assert_not_nil @org_permission.archive_date, @org_permission.archive_date
        assert_not_nil @another_org_permission.archive_date, @another_org_permission.archive_date
      end
    end
    context "USER request" do
      setup do
        @token = @user_token.code
      end
      should 'not bulk archive ADMIN organizational_permissions' do
        @org_permission.update_attributes(permission_id: @admin_permission.id)
        @another_org_permission.update_attributes(permission_id: @admin_permission.id)
        post :bulk_archive, access_token: @token,
              filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@admin_permission.id}"
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        @org_permission.reload
        @another_org_permission.reload
        assert_nil @org_permission.archive_date, @org_permission.archive_date
        assert_nil @another_org_permission.archive_date, @another_org_permission.archive_date
      end
      should 'bulk archive USER organizational_permissions' do
        @org_permission.update_attributes(permission_id: @user_permission.id)
        @another_org_permission.update_attributes(permission_id: @user_permission.id)
        post :bulk_archive, access_token: @token,
              filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@user_permission.id}"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        @org_permission.reload
        @another_org_permission.reload
        assert_not_nil @org_permission.archive_date, @org_permission.archive_date
        assert_not_nil @another_org_permission.archive_date, @another_org_permission.archive_date
      end
      should 'bulk archive CONTACT organizational_permissions' do
        @org_permission.update_attributes(permission_id: @contact_permission.id)
        @another_org_permission.update_attributes(permission_id: @contact_permission.id)
        post :bulk_archive, access_token: @token,
              filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@contact_permission.id}"
        assert_response :success
        json = JSON.parse(response.body)
        assert_equal 2, json['people'].count, json.inspect
        @org_permission.reload
        @another_org_permission.reload
        assert_not_nil @org_permission.archive_date, @org_permission.archive_date
        assert_not_nil @another_org_permission.archive_date, @another_org_permission.archive_date
      end
    end
    context "NO_PERMISSION request" do
      setup do
        @token = @no_permission_token.code
      end
      should 'not bulk archive ADMIN organizational_permissions' do
        @org_permission.update_attributes(permission_id: @admin_permission.id)
        @another_org_permission.update_attributes(permission_id: @admin_permission.id)
        post :bulk_archive, access_token: @token,
              filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@admin_permission.id}"
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        @org_permission.reload
        @another_org_permission.reload
        assert_nil @org_permission.archive_date, @org_permission.archive_date
        assert_nil @another_org_permission.archive_date, @another_org_permission.archive_date
      end
      should 'not bulk archive USER organizational_permissions' do
        @org_permission.update_attributes(permission_id: @user_permission.id)
        @another_org_permission.update_attributes(permission_id: @user_permission.id)
        post :bulk_archive, access_token: @token,
              filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@user_permission.id}"
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        @org_permission.reload
        @another_org_permission.reload
        assert_nil @org_permission.archive_date, @org_permission.archive_date
        assert_nil @another_org_permission.archive_date, @another_org_permission.archive_date
      end
      should 'not bulk archive CONTACT organizational_permissions' do
        @org_permission.update_attributes(permission_id: @contact_permission.id)
        @another_org_permission.update_attributes(permission_id: @contact_permission.id)
        post :bulk_archive, access_token: @token,
              filters: {ids: "#{@person.id},#{@another_person.id}"}, permission: "#{@contact_permission.id}"
        json = JSON.parse(response.body)
        assert_not_nil json["errors"], json.inspect
        @org_permission.reload
        @another_org_permission.reload
        assert_nil @org_permission.archive_date, @org_permission.archive_date
        assert_nil @another_org_permission.archive_date, @another_org_permission.archive_date
      end
    end
  end


  # setup do
  #   request.env['HTTP_ACCEPT'] = 'application/json'
  #   @client = Factory(:client)
  #   @user = Factory(:user_no_org)
  #   @person = @user.person
  #   @org = @client.organization

  #   @org.add_admin(@person)
  #   @label = Factory(:label, organization: @org)

  #   Factory(:organizational_label, organization: @org, person: @person, label: @label)

  #   @person1 = Factory(:person)
  #   @org.add_contact(@person1)
  #   @person2 = Factory(:person)
  #   @org.add_contact(@person2)
  #   @org_permission = @org.organizational_permissions.last
  #   @permission_contact = @person2.permission_for_org_id(@org.id)
  #   @label1 = Factory(:label, organization: @org)

  #   @admin_permission = Permission.find_or_create_by_i18n("admin")
  #   @user_permission = Permission.find_or_create_by_i18n("user")
  #   @contact_permission = Permission.find_or_create_by_i18n("no_permissions")
  # end

  # context '.index' do
  #   should "return a list of organization's organizational_permissions" do
  #     get :index, secret: @client.secret
  #     json = JSON.parse(response.body)
  #     assert_equal @org.organizational_permissions.count, json['organizational_permissions'].count, json.inspect
  #   end
  # end

  # context '.show' do
  #   should 'return an organizational_permission' do
  #     get :show, id: @org_permission.id, secret: @client.secret
  #     json = JSON.parse(response.body)
  #     assert_equal @org_permission.id, json['organizational_permission']['id'], json.inspect
  #   end
  # end

  # context '.create' do
  #   should 'create and return an organizational_permission' do
  #     @person3 = Factory(:person)
  #     assert_difference "OrganizationalPermission.count" do
  #       post :create, organizational_permission: {permission_id: @permission_contact.id, person_id: @person3.id}, secret: @client.secret
  #     end
  #     json = JSON.parse(response.body)
  #     assert_equal @person3.id, json['organizational_permission']['person_id'], json.inspect
  #   end
  # end

  # context '.update' do
  #   should 'create and return an organizational_permission' do
  #     put :update, id: @org_permission.id, organizational_permission: {archive_date: '2013-01-01'}, secret: @client.secret
  #     json = JSON.parse(response.body)
  #     assert_equal '2013-01-01'.to_date, json['organizational_permission']['archive_date'].to_date, json.inspect
  #   end
  # end

  # context '.destroy' do
  #   should 'create and return an organizational_permission' do
  #     delete :destroy, id: @org_permission.id, secret: @client.secret
  #     @org_permission.reload
  #     assert_not_nil @org_permission.archive_date, @org_permission.inspect
  #   end
  # end



  # context '.bulk' do
  #   setup do
  #     @contact1 = Factory(:person)
  #     @org.add_contact(@contact1)
  #     @contact2 = Factory(:person)
  #     @org.add_contact(@contact2)
  #     @admin_permission = Permission.find_by_i18n("admin")
  #   end
  #   should 'create and destroy bulk organizational_permissions' do
  #     EmailAddress.create(person_id: @contact1.id, email: "contact1email@x.com")
  #     EmailAddress.create(person_id: @contact2.id, email: "contact2email@x.com")
  #     get :bulk, filters: {ids: "#{@contact1.id},#{@contact2.id}"}, add_permission: "#{@admin_permission.id}", remove_permission: "#{@permission_contact.id}", secret: @client.secret, order: 'created_at'
  #     assert_response :success
  #     json = JSON.parse(response.body)
  #     assert_equal 2, json['people'].count, json.inspect
  #     assert_equal @admin_permission.id, @contact1.permissions.first.id
  #     assert_equal @admin_permission.id, @contact2.permissions.first.id
  #     assert !@contact1.permissions.include?(@permission_contact), @contact1.permissions.inspect
  #     assert !@contact2.permissions.include?(@permission_contact), @contact2.permissions.inspect
  #   end
  # end

  # context '.bulk_create' do
  #   setup do
  #     @contact1 = Factory(:person)
  #     @contact2 = Factory(:person)
  #     @another_admin = Factory(:person)
  #     @org.add_admin(@another_admin)
  #   end
  #   # Tests will be updated in MH-727

  #   # should 'replace contact to admin permissions' do
  #   #   @org.add_permission_to_person(@contact1, @contact_permission.id)
  #   #   @org.add_permission_to_person(@contact2, @contact_permission.id)
  #   #   post :bulk_create, filters: {ids: "#{@contact1.id},#{@contact2.id}"}, permission: "#{@admin_permission.id}", secret: @client.secret, order: 'created_at'
  #   #   assert_response :success
  #   #   json = JSON.parse(response.body)
  #   #   assert_equal 2, json['people'].count, json.inspect
  #   #   assert_equal @admin_permission.id, @contact1.permissions.first.id
  #   #   assert_equal @admin_permission.id, @contact2.permissions.first.id
  #   # end
  #   # should 'replace contact to leader permissions' do
  #   #   @org.add_permission_to_person(@contact1, @contact_permission.id)
  #   #   @org.add_permission_to_person(@contact2, @contact_permission.id)
  #   #   post :bulk_create, filters: {ids: "#{@contact1.id},#{@contact2.id}"}, permission: "#{@user_permission.id}", secret: @client.secret, order: 'created_at'
  #   #   assert_response :success
  #   #   json = JSON.parse(response.body)
  #   #   assert_equal 2, json['people'].count, json.inspect
  #   #   assert_equal @user_permission.id, @contact1.permissions.first.id
  #   #   assert_equal @user_permission.id, @contact2.permissions.first.id
  #   # end
  #   # should 'replace leader to admin permissions' do
  #   #   @org.add_permission_to_person(@contact1, @user_permission.id)
  #   #   @org.add_permission_to_person(@contact2, @user_permission.id)
  #   #   post :bulk_create, filters: {ids: "#{@contact1.id},#{@contact2.id}"}, permission: "#{@admin_permission.id}", secret: @client.secret, order: 'created_at'
  #   #   assert_response :success
  #   #   json = JSON.parse(response.body)
  #   #   assert_equal 2, json['people'].count, json.inspect
  #   #   assert_equal @admin_permission.id, @contact1.permissions.first.id
  #   #   assert_equal @admin_permission.id, @contact2.permissions.first.id
  #   # end
  #   # should 'ignore contact over admin permissions' do
  #   #   @org.add_permission_to_person(@contact1, @admin_permission.id)
  #   #   @org.add_permission_to_person(@contact2, @admin_permission.id)
  #   #   post :bulk_create, filters: {ids: "#{@contact1.id},#{@contact2.id}"}, permission: "#{@contact_permission.id}", secret: @client.secret, order: 'created_at'
  #   #   json = JSON.parse(response.body)
  #   #   raise json.inspect
  #   #   # assert_equal 2, json['people'].count, json.inspect
  #   #   assert_equal @admin_permission.id, @contact1.permissions.first.id
  #   #   assert_equal @admin_permission.id, @contact2.permissions.first.id
  #   # end
  #   # should 'ignore leader over admin permissions' do
  #   #   @org.add_permission_to_person(@contact1, @admin_permission.id)
  #   #   @org.add_permission_to_person(@contact2, @admin_permission.id)
  #   #   post :bulk_create, filters: {ids: "#{@contact1.id},#{@contact2.id}"}, permission: "#{@user_permission.id}", secret: @client.secret, order: 'created_at'
  #   #   assert_response :success
  #   #   json = JSON.parse(response.body)
  #   #   assert_equal 2, json['people'].count, json.inspect
  #   #   assert_equal @admin_permission.id, @contact1.permissions.first.id
  #   #   assert_equal @admin_permission.id, @contact2.permissions.first.id
  #   # end
  #   # should 'ignore contact over leader permissions' do
  #   #   @org.add_permission_to_person(@contact1, @user_permission.id)
  #   #   @org.add_permission_to_person(@contact2, @user_permission.id)
  #   #   post :bulk_create, filters: {ids: "#{@contact1.id},#{@contact2.id}"}, permission: "#{@contact_permission.id}", secret: @client.secret, order: 'created_at'
  #   #   assert_response :success
  #   #   json = JSON.parse(response.body)
  #   #   assert_equal 2, json['people'].count, json.inspect
  #   #   assert_equal @user_permission.id, @contact1.permissions.first.id
  #   #   assert_equal @user_permission.id, @contact2.permissions.first.id
  #   # end
  # end


  # context '.bulk_destroy' do
  #   should 'destroy bulk organizational_permissions' do
  #     delete :bulk_destroy, filters: {ids: "#{@person1.id},#{@person2.id}"}, permission: "#{@contact_permission.id}", secret: @client.secret, order: 'created_at'
  #     assert_response :success
  #     json = JSON.parse(response.body)
  #     assert_equal 2, json['people'].count, json.inspect
  #     assert !@person1.permissions.include?(@permission1), @person1.permissions.inspect
  #     assert !@person2.permissions.include?(@permission1), @person2.permissions.inspect
  #   end
  # end


  # context '.bulk_archive' do
  #   should 'archive bulk organizational_permissions' do
  #     post :bulk_archive, filters: {ids: "#{@person1.id},#{@person2.id}"}, permission: "#{@contact_permission.id}", secret: @client.secret, order: 'created_at'
  #     assert_response :success
  #     json = JSON.parse(response.body)
  #     assert_equal 2, json['people'].count, json.inspect
  #     assert !@person1.permissions.include?(@permission1), @person1.permissions.inspect
  #     assert !@person2.permissions.include?(@permission1), @person2.permissions.inspect
  #   end
  # end

end
