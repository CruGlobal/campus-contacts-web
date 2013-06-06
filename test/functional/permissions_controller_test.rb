require 'test_helper'

class PermissionsControllerTest < ActionController::TestCase
  context "Before logging in" do
    should "redirect on update" do
      user = Factory(:person)
      put :update, id: Permission.first.id
      assert_redirected_to '/users/sign_in'
    end
  end

  context "After logging in a person with orgs" do
    setup do
      @user = Factory(:user_with_auxs)
      @organization = @user.person.organizational_permissions.first.organization
      @test_permission = Permission.create!(:name => 'member')
      sign_in @user
    end

    should "show all the system and organizational permissions" do
      @organization.update_attribute('ancestry','2')
      get :index, :id => @organization.id
      system_permissions = assigns(:system_permissions).collect { |permission| permission.i18n }
      organizational_permissions = assigns(:organizational_permissions).collect { |permission| permission.i18n }
      assert_response :success, @response.body
      assert_equal ["admin", "user", "no_permissions"], system_permissions
    end

    should "should get new" do
      get :new
      assert_response :success
    end

    context ", creating a permission" do
      should "create a permission" do
        assert_difference('Permission.count') do
          post :create, :permission => { "name" => "permission one", "i18n" => "permission one" }
        end
        assert_redirected_to permissions_path
      end

      should "not create a permission with missing required fields" do
        assert_no_difference('Permission.count') do
          post :create
        end
        assert_template "permissions/new"
      end

      should "not create a permission if it's already created in the organization (same name and org)" do
        permission = Factory(:permission, organization: @organization)

        assert_no_difference 'Permission.count' do
          post :create_now, { :name => permission.name }
        end

        assert_equal I18n.t('contacts.index.add_label_exists'), assigns(:msg_alert)

      end

      should "not create a permission if name params is absent" do
        assert_no_difference 'Permission.count' do
          post :create_now
        end

        assert_equal I18n.t('contacts.index.add_label_empty'), assigns(:msg_alert)

      end
    end

    should "create a permission using ajax" do
      assert_difference('Permission.count') do
        xhr :post, :create_now, :name => "permission one"
      end
    end

    should "create a permission" do
      assert_difference('Permission.count') do
        post :create, :permission => { "name" => "permission one", "i18n" => "permission one" }
      end
      assert_redirected_to permissions_path
    end

    should "should get edit" do
      get :edit, :id => @test_permission.id
      assert_response :success
    end

    context ", updating a permission" do
      should "update a permission" do
        put :update, :id => @test_permission.id, :permission => { "i18n" => "permission two" }
        assert_equal 'permission two', assigns(:permission).i18n
        assert_redirected_to permissions_path
      end

      should "not update a permission with missing required fields" do
        put :update, :id => @test_permission.id, :permission => { "name" => nil }
        assert_template "permissions/edit"
      end
    end

    should "destroy a permission" do
      assert_difference('Permission.count', -1) do
        delete :destroy, :id => @test_permission.id
      end
      assert_redirected_to permissions_path
    end
  end
end
