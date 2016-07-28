require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase
  context 'Organizations' do
    setup do
      @user = FactoryGirl.create(:user_with_auxs) # user with a person object
      sign_in @user
      @org_parent = FactoryGirl.create(:organization)
      @org_parent.add_admin(@user.person)
      @org_child = FactoryGirl.create(:organization, name: 'neilmarion', parent: @org_parent)
    end

    context 'creating' do
      should "create a child org if it's name is unique, otherwise dont create a child org" do
        assert_difference 'Organization.count', 0 do
          xhr :post, :create, organization: { parent_id: @org_parent.id, name: 'neilmarion', terminology: 'Organization', show_sub_orgs: '1' }
        end

        assert_difference 'Organization.count', 1 do
          xhr :post, :create, organization: { parent_id: @org_parent.id, name: 'notneilmarion', terminology: 'Organization', show_sub_orgs: '1' }
          assert @org_parent.children.collect(&:name).include? 'notneilmarion'
        end
      end

      # TODO: fix this
      # should "clear cache of anyone who should see this org in their nav menu" do
      # OrganizationsController.any_instance.expects(:expire_fragment).with("org_nav/#{@user.person.id}")

      # xhr :post, :create, {:organization => {:parent_id => @org_parent.id, :name => "notneilmarion", :terminology => "Organization", :show_sub_orgs => "1"}}
      # end

      # context "from crs" do
      #  should "create from crs" do
      # Ccc::Crs2Conference.create(admin_password: "hello", begin_date: Date.today, creator_id: 2, end_date: Date.today + 30, registration_ends_at: Date.today + 10, registration_starts_at: Date.today + 1, version: 1)
      #  end
      # end
    end

    # context 'deleting' do
    # should "clear cache of anyone who has a permission in a grandparent of this org" do
    # @org_grandchild = FactoryGirl.create(:organization, :name => "foo", :parent => @org_child)
    # OrganizationsController.any_instance.expects(:expire_fragment).with("org_nav/#{@user.person.id}")
    # post :destroy, id: @org_grandchild.id
    # end

    # should "clear cache of anyone who has a permission in a parent of this org" do
    # OrganizationsController.any_instance.expects(:expire_fragment).with("org_nav/#{@user.person.id}")
    # post :destroy, id: @org_parent.id
    # end
    # end

    context 'updating' do
      should 'update' do
        xhr :put, :update, { organization: { name: 'Organization One', terminology: 'Organization', show_sub_orgs: '1' }, id: @org_parent.id }
        assert_response :redirect
      end

      should 'fail updating' do
        xhr :put, :update, organization: { name: '', terminology: 'Organization', show_sub_orgs: '1' }, id: @org_parent.id
        assert_response :success
      end
    end

    context 'settings' do
      should 'load settigns page' do
        xhr :put, :settings
        assert_response :success
      end

      should 'assign false as the default value for the check box' do
        get :settings
        assert(!assigns(:show_year_in_school))
      end

      should 'successfully update org settings' do
        post :update_settings, show_year_in_school: 'on'
        assert_response(:redirect)
        assert('Successfully updated org settings!', flash[:notice])
        get :settings
        assert(assigns(:show_year_in_school))
      end

      should 'update the settings' do
        post :update_settings, show_year_in_school: 'off'
        assert_response(:redirect)
        assert('Successfully updated org settings!', flash[:notice])
        get :settings
        assert(!assigns(:show_year_in_school))
      end

      should 'fail update settings' do
        org = FactoryGirl.build(:organization, name: nil)
        org.save(validate: false)
        user = FactoryGirl.create(:user_with_auxs)
        org.add_admin(user.person)
        sign_in user
        @request.session[:current_organization_id] = org.id

        xhr :post, :update_settings, show_year_in_school: 'on'
        assert_response :redirect
      end
    end
  end
  # context "when updating org settings" do
  # setup do
  # @user = FactoryGirl.create(:user_with_auxs)
  # sign_in @user
  # end

  # context "and the org settings hash is empty" do
  # setup do
  # @org = FactoryGirl.create(:organization)
  # FactoryGirl.create(:organizational_permission, organization: @org, person: @user.person, permission: Permission.admin)

  # @request.session[:current_organization_id] = @org.id
  # end

  # should "assign false as the default value for the check box" do
  # get :settings
  # assert(!assigns(:show_year_in_school))
  # end

  # should "successfully update org settings" do
  # post :update_settings, { :show_year_in_school => "on" }
  # assert_response(:redirect)
  # assert("Successfully updated org settings!",flash[:notice])
  # get :settings
  # assert(assigns(:show_year_in_school))
  # end

  # should "update the settings" do
  # post :update_settings, { :show_year_in_school => "off" }
  # assert_response(:redirect)
  # assert("Successfully updated org settings!",flash[:notice])
  # get :settings
  # assert(!assigns(:show_year_in_school))
  # end
  # end
  # end

  # setup do
  #   @organization = organizations(:one)
  # end
  #
  # test "should get index" do
  #   get :index
  #   assert_response :success
  #   assert_not_nil assigns(:organizations)
  # end
  #
  # test "should get new" do
  #   get :new
  #   assert_response :success
  # end
  #
  # test "should create organization" do
  #   assert_difference('Admin::Organization.count') do
  #     post :create, organization: @organization.attributes
  #   end
  #
  #   assert_redirected_to admin_organization_path(assigns(:organization))
  # end
  #
  # test "should show organization" do
  #   get :show, id: @organization.to_param
  #   assert_response :success
  # end
  #
  # test "should get edit" do
  #   get :edit, id: @organization.to_param
  #   assert_response :success
  # end
  #
  # test "should update organization" do
  #   put :update, id: @organization.to_param, organization: @organization.attributes
  #   assert_redirected_to admin_organization_path(assigns(:organization))
  # end
  #
  # test "should destroy organization" do
  #   assert_difference('Admin::Organization.count', -1) do
  #     delete :destroy, id: @organization.to_param
  #   end
  #
  #   assert_redirected_to organizations_path
  # end
  setup do
    @user, @org = admin_user_login_with_org
  end

  should 'get index' do
    get :index
    assert_response :success
  end

  should 'get show' do
    xhr :get, :show, id: @request.session[:current_organization_id]
    assert_not_nil assigns(:organization)
  end

  should 'get edit' do
    get :edit, id: @request.session[:current_organization_id]
    assert_not_nil assigns(:organization)
  end

  should 'get thanks' do
    get :thanks
    assert_template 'layouts/splash'
  end

  should 'not save when bad params' do
    post :signup, organization: { name: 'wat' }
    assert_template 'layouts/splash'
  end

  should 'redirect on save with good parameters' do
    post :signup, organization: { name: 'wat', terminology: 'wat' }
    assert_response :redirect
  end

  should 'get organizations when searching' do
    org1 = FactoryGirl.create(:organization, parent: @org, name: 'Test2')
    org2 = FactoryGirl.create(:organization, parent: @org, name: 'Test1')

    xhr :get, :search, q: 'Test'
    assert_not_nil assigns(:organizations)
    assert_not_nil assigns(:total)

    assert assigns(:organizations).include? org1
    assert assigns(:organizations).include? org2
  end

  should 'create org' do
    xhr :post, :create, organization: { name: 'Wat', terminology: 'Wat', parent_id: @org.id }
    assert_not_nil assigns(:parent)
    assert_not_nil assigns(:organization)
  end

  context 'Archiving Contacts' do
    setup do
      @contact1 = FactoryGirl.create(:person)
      FactoryGirl.create(:organizational_permission, organization: @org, person: @contact1, permission: Permission.no_permissions)
      @contact2 = FactoryGirl.create(:person)
      FactoryGirl.create(:organizational_permission, organization: @org, person: @contact2, permission: Permission.no_permissions)
      @contact3 = FactoryGirl.create(:person)
      FactoryGirl.create(:organizational_permission, organization: @org, person: @contact3, permission: Permission.no_permissions)
    end

    should 'redirect to cleanup page' do
      xhr :get, :cleanup
      assert_response :success
    end

    should 'archive contacts' do
      @contact3.organizational_permissions.where(permission_id: Permission::NO_PERMISSIONS_ID, organization_id: @org.id).first.update_attributes(archive_date: (Date.today).strftime('%Y-%m-%d'))
      @contact2.organizational_permissions.where(permission_id: Permission::NO_PERMISSIONS_ID, organization_id: @org.id).first.update_attributes(archive_date: (Date.today).strftime('%Y-%m-%d'))
      @contact1.organizational_permissions.where(permission_id: Permission::NO_PERMISSIONS_ID, organization_id: @org.id).first.update_attributes(archive_date: (Date.today).strftime('%Y-%m-%d'))

      post :archive_contacts, archive_contacts_before: Date.today.strftime('%m-%d-%Y')
      assert_equal @org.all_people_with_archived.archived(@org.id).count, 3
    end

    should 'not delete contact permissions' do
      assert_no_difference('OrganizationalPermission.count') do
        post :archive_contacts, archive_contacts_before: Date.today.strftime('%m-%d-%Y')
      end
    end

    should 'archive contacts with the chosen time' do
      chosen_date = (Date.today).strftime('%Y-%m-%d')
      @contact3.organizational_permissions.where(permission_id: Permission::NO_PERMISSIONS_ID, organization_id: @org.id).first.update_attributes(archive_date: chosen_date)
      @contact2.organizational_permissions.where(permission_id: Permission::NO_PERMISSIONS_ID, organization_id: @org.id).first.update_attributes(archive_date: chosen_date)
      @contact1.organizational_permissions.where(permission_id: Permission::NO_PERMISSIONS_ID, organization_id: @org.id).first.update_attributes(archive_date: chosen_date)
      post :archive_contacts, archive_contacts_before: Date.today.strftime('%Y-%m-%d')
      assert_equal 3, @org.all_people_with_archived.where('DATE(archive_date) <= ?', chosen_date).archived(@org.id).count
    end
  end

  context 'Archiving Contacts when no contacts' do
    should 'redirect to cleanup page' do
      post :archive_contacts, archive_contacts_before: (Date.today - 30).strftime('%m-%d-%Y')
      assert_equal 0, @org.people.archived(@org.id).count
      assert_redirected_to cleanup_organizations_path
    end
  end

  context 'Archiving leaders' do
    setup do
      @leader1 = FactoryGirl.create(:user_with_auxs)
      FactoryGirl.create(:organizational_permission, organization: @org, person: @leader1.person, permission: Permission.user)
      @leader2 = FactoryGirl.create(:user_with_auxs)
      FactoryGirl.create(:organizational_permission, organization: @org, person: @leader2.person, permission: Permission.user)
      @leader3 = FactoryGirl.create(:user_with_auxs)
      FactoryGirl.create(:organizational_permission, organization: @org, person: @leader3.person, permission: Permission.user)
    end

    should 'archive leaders' do
      @leader1.person.organizational_permissions.where(permission_id: Permission::USER_ID, organization_id: @org.id).first.update_attributes(archive_date: (Date.today).strftime('%Y-%m-%d'))
      @leader2.person.organizational_permissions.where(permission_id: Permission::USER_ID, organization_id: @org.id).first.update_attributes(archive_date: (Date.today).strftime('%Y-%m-%d'))
      @leader3.person.organizational_permissions.where(permission_id: Permission::USER_ID, organization_id: @org.id).first.update_attributes(archive_date: (Date.today).strftime('%Y-%m-%d'))

      post :archive_leaders, date_leaders_not_logged_in_after: Date.today.strftime('%Y-%m-%d')
      assert_equal @org.all_people_with_archived.archived(@org.id).count, 3
    end

    should 'not delete leader permissions' do
      assert_no_difference('OrganizationalPermission.count') do
        post :archive_leaders, date_leaders_not_logged_in_after: Date.today.strftime('%m-%d-%Y')
      end
    end
  end

  context 'Archiving leaders when no leaders' do
    should 'redirect to cleanup page' do
      post :archive_leaders, date_leaders_not_logged_in_after: (Date.today - 30).strftime('%m-%d-%Y')
      assert_equal @org.people.archived(@org.id).count, 0
      assert_redirected_to cleanup_organizations_path
    end
  end

  context '100% Sent feature' do
    setup do
      @user, @organization = admin_user_login_with_org
      @admin = @user.person
      @sent_org = FactoryGirl.create(:organization, id: 472, name: 'CM 100% Sent Team')
      @contact1 = FactoryGirl.create(:person, first_name: 'abby')
      @contact2 = FactoryGirl.create(:person, first_name: 'belly')
      @contact3 = FactoryGirl.create(:person, first_name: 'cassy')
      @contact4 = FactoryGirl.create(:person, first_name: 'daisy')
      @contact5 = FactoryGirl.create(:person, first_name: 'elssy')

      FactoryGirl.create(:organizational_permission, person: @contact1, permission: Permission.no_permissions, organization: @org)
      FactoryGirl.create(:organizational_permission, person: @contact2, permission: Permission.no_permissions, organization: @org)
      FactoryGirl.create(:organizational_permission, person: @contact3, permission: Permission.no_permissions, organization: @org)
      FactoryGirl.create(:organizational_permission, person: @contact4, permission: Permission.no_permissions, organization: @org)
      FactoryGirl.create(:organizational_permission, person: @contact5, permission: Permission.no_permissions, organization: @org)

      graduating_on_mission = InteractionType.graduating_on_mission
      other_interaction = InteractionType.comment
      FactoryGirl.create(:interaction, interaction_type_id: graduating_on_mission.id, receiver: @contact1, creator: @admin, organization: @org)
      FactoryGirl.create(:interaction, interaction_type_id: graduating_on_mission.id, receiver: @contact2, creator: @admin, organization: @org)
      FactoryGirl.create(:interaction, interaction_type_id: graduating_on_mission.id, receiver: @contact3, creator: @admin, organization: @org)
      FactoryGirl.create(:interaction, interaction_type_id: other_interaction.id, receiver: @contact4, creator: @admin, organization: @org)
      FactoryGirl.create(:interaction, interaction_type_id: other_interaction.id, receiver: @contact5, creator: @admin, organization: @org)

      FactoryGirl.create(:sent_person, person: @contact3)
    end
    should 'suggest available contacts when adding contacts to 100% Sent pending list' do
      xhr :get, :available_for_transfer, term: 's'
      assert assigns(:people).include?(@contact4), 'contact should be suggested'
      assert assigns(:people).include?(@contact5), 'contact should be suggested'
      assert_equal false, assigns(:people).include?(@contact3), 'contact should not be suggested'
      assert_equal 2, assigns(:people).count, '2 contacts should be suggested'
    end
    should 'add contact to transfer queue' do
      assert_equal false, @organization.pending_transfer.include?(@contact4), 'contact should not be in the list yet'
      xhr :get, :queue_transfer, person_id: @contact4.id, format: 'js'
      assert @organization.pending_transfer.include?(@contact4), 'contact should be in the list'
    end
    should 'display all pending contacts for transfer' do
      get :transfer
      assert_equal @organization.pending_transfer.count, assigns(:pending_transfer).count
    end
    should 'transfer checked contacts' do
      post :do_transfer, ids: [@contact4.id, @contact5.id]
      assert assigns(:sent_team_org) == @sent_org, 'transfer destination should be 100% Sent Team'
      assert @sent_org.all_people.include?(@contact4), 'contact should be transferred'
      assert @sent_org.all_people.include?(@contact5), 'contact should be transferred'
      assert SentPerson.find_by_person_id(@contact4.id), 'contact should be marked as sent'
      assert SentPerson.find_by_person_id(@contact5.id), 'contact should be marked as sent'
    end
    should 'transfer checked contacts and mark contacts as alumni' do
      post :do_transfer, ids: [@contact4.id], tag_as_alumni: '1'
      alumni_label = @organization.labels.find_by_name('Alumni')
      assert OrganizationalLabel.exists?(label_id: alumni_label.id, person_id: @contact4.id, organization_id: @organization.id), 'contact should have an alumni label'
    end
    should 'transfer checked contacts and archive contacts' do
      # FactoryGirl.create(:organizational_permission, person: @contact5, permission_id: Permission::NO_PERMISSIONS_ID, organization: @organization)
      post :do_transfer, ids: [@contact5.id], tag_as_archived: '1'
      contact_permission = OrganizationalPermission.find_by_permission_id_and_person_id_and_organization_id(Permission::NO_PERMISSIONS_ID, @contact5.id, @organization.id)
      assert !contact_permission.archive_date.nil?, 'old contact should be archived'
    end
  end
end
