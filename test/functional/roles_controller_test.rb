require 'test_helper'

class RolesControllerTest < ActionController::TestCase
  context "Before logging in" do
    should "redirect on update" do
      user = Factory(:person)
      put :update, id: Role.first.id
      assert_redirected_to '/users/sign_in'
    end
  end

  context "After logging in a person with orgs" do
    setup do
      @user = Factory(:user_with_auxs)
      @organization = @user.person.organizational_roles.first.organization
      @test_role = Role.create!(:name => 'member', :organization_id => @organization.id)
      sign_in @user
    end

    should "show all the system and organizational roles for CRU child org" do
      get :index, :id => @organization.id
      system_roles = assigns(:system_roles).collect { |role| role.i18n }
      organizational_roles = assigns(:organizational_roles).collect { |role| role.name.downcase }
      assert_response :success, @response.body
      assert_equal ["admin", "leader", "involved", "alumni", "contact", "sent"], system_roles
      assert_equal ["member"], organizational_roles
    end

    should "show all the system and organizational roles" do
      @organization.update_attribute('ancestry','2')
      get :index, :id => @organization.id
      system_roles = assigns(:system_roles).collect { |role| role.i18n }
      organizational_roles = assigns(:organizational_roles).collect { |role| role.i18n }
      assert_response :success, @response.body
      assert_equal ["admin", "leader", "involved", "alumni", "contact"], system_roles
    end

    should "should get new" do
      get :new
      assert_response :success
    end

    context ", creating a role" do
      should "create a role" do
        assert_difference('Role.count') do
          post :create, :role => { "name" => "role one", "i18n" => "role one" }
        end
        assert_redirected_to roles_path
      end

      should "not create a role with missing required fields" do
        assert_no_difference('Role.count') do
          post :create
        end
        assert_template "roles/new"
      end

      should "not create a role if it's already created in the organization (same name and org)" do
        role = Factory(:role, organization: @organization)

        assert_no_difference 'Role.count' do
          post :create_now, { :name => role.name }
        end

        assert_equal I18n.t('contacts.index.add_label_exists'), assigns(:msg_alert)

      end

      should "not create a role if name params is absent" do
        assert_no_difference 'Role.count' do
          post :create_now
        end

        assert_equal I18n.t('contacts.index.add_label_empty'), assigns(:msg_alert)

      end
    end

    should "create a role using ajax" do
      assert_difference('Role.count') do
        xhr :post, :create_now, :name => "role one"
      end
    end

    should "create a role" do
      assert_difference('Role.count') do
        post :create, :role => { "name" => "role one", "i18n" => "role one" }
      end
      assert_redirected_to roles_path
    end

    should "should get edit" do
      get :edit, :id => @test_role.id
      assert_response :success
    end

    context ", updating a role" do
      should "update a role" do
        put :update, :id => @test_role.id, :role => { "i18n" => "role two" }
        assert_equal 'role two', assigns(:role).i18n
        assert_redirected_to roles_path
      end

      should "not update a role with missing required fields" do
        put :update, :id => @test_role.id, :role => { "name" => nil }
        assert_template "roles/edit"
      end
    end

    should "destroy a role" do
      assert_difference('Role.count', -1) do
        delete :destroy, :id => @test_role.id
      end
      assert_redirected_to roles_path
    end
  end
end
