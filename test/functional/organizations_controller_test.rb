require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase

  context "Organizations" do
    setup do
      @user = Factory(:user_with_auxs)  #user with a person object
      sign_in @user
      @org_parent = Factory(:organization)
      @org_parent.add_admin(@user.person)
      @org_child = Factory(:organization, :name => "neilmarion", :parent => @org_parent)
    end

    context "creating" do
      should "create a child org if it's name is unique, otherwise dont create a child org" do
        xhr :post, :create, {:organization => {:parent_id => @org_parent.id, :name => "neilmarion", :terminology => "Organization", :show_sub_orgs => "1"}}
        assert_equal 1, @org_parent.children.count

        xhr :post, :create, {:organization => {:parent_id => @org_parent.id, :name => "notneilmarion", :terminology => "Organization", :show_sub_orgs => "1"}}
        assert_equal 2, @org_parent.children.count
        assert @org_parent.children.collect {|c| c.name }.include? "notneilmarion"
      end

      # TODO: fix this
      #should "clear cache of anyone who should see this org in their nav menu" do
        #OrganizationsController.any_instance.expects(:expire_fragment).with("org_nav/#{@user.person.id}")

        #xhr :post, :create, {:organization => {:parent_id => @org_parent.id, :name => "notneilmarion", :terminology => "Organization", :show_sub_orgs => "1"}}
      #end

      #context "from crs" do
      #  should "create from crs" do
          #Ccc::Crs2Conference.create(admin_password: "hello", begin_date: Date.today, creator_id: 2, end_date: Date.today + 30, registration_ends_at: Date.today + 10, registration_starts_at: Date.today + 1, version: 1)
      #  end
      #end
    end

    #context 'deleting' do
      #should "clear cache of anyone who has a role in a grandparent of this org" do
        #@org_grandchild = Factory(:organization, :name => "foo", :parent => @org_child)
        #OrganizationsController.any_instance.expects(:expire_fragment).with("org_nav/#{@user.person.id}")
        #post :destroy, id: @org_grandchild.id
      #end

      #should "clear cache of anyone who has a role in a parent of this org" do
        #OrganizationsController.any_instance.expects(:expire_fragment).with("org_nav/#{@user.person.id}")
        #post :destroy, id: @org_parent.id
      #end
    #end

    context "updating" do
      should "update" do
        xhr :put, :update, {:organization => {:name =>"Organization One", :terminology => "Organization", :show_sub_orgs => "1"}, :id => @org_parent.id}
        assert_response :redirect
      end

      should "fail updating" do
        xhr :put, :update, {:organization => {:name =>"", :terminology => "Organization", :show_sub_orgs => "1"}, :id => @org_parent.id}
        assert_response :success
      end
    end

    context "settings" do
      should "load settigns page" do
        xhr :put, :settings
        assert_response :success
      end

      should "assign false as the default value for the check box" do
        get :settings
        assert(!assigns(:show_year_in_school))
      end

      should "successfully update org settings" do
        post :update_settings, { :show_year_in_school => "on" }
        assert_response(:redirect)
        assert("Successfully updated org settings!",flash[:notice])
        get :settings
        assert(assigns(:show_year_in_school))
      end

      should "update the settings" do
        post :update_settings, { :show_year_in_school => "off" }
        assert_response(:redirect)
        assert("Successfully updated org settings!",flash[:notice])
        get :settings
        assert(!assigns(:show_year_in_school))
      end

      should "fail update settings" do
        org = Factory.build(:organization, name: nil)
        org.save(:validate => false)
        user = Factory(:user_with_auxs)
        org.add_admin(user.person)
        sign_in user
        @request.session[:current_organization_id] = org.id

        xhr :post, :update_settings, { :show_year_in_school =>"on" }
        assert_response :redirect
      end
    end

  end
  #context "when updating org settings" do
    #setup do
      #@user = Factory(:user_with_auxs)
      #sign_in @user
    #end

    #context "and the org settings hash is empty" do
      #setup do
        #@org = Factory(:organization)
        #Factory(:organizational_role, organization: @org, person: @user.person, role: Role.admin)

        #@request.session[:current_organization_id] = @org.id
      #end

      #should "assign false as the default value for the check box" do
        #get :settings
        #assert(!assigns(:show_year_in_school))
      #end

      #should "successfully update org settings" do
        #post :update_settings, { :show_year_in_school => "on" }
        #assert_response(:redirect)
        #assert("Successfully updated org settings!",flash[:notice])
        #get :settings
        #assert(assigns(:show_year_in_school))
      #end

      #should "update the settings" do
        #post :update_settings, { :show_year_in_school => "off" }
        #assert_response(:redirect)
        #assert("Successfully updated org settings!",flash[:notice])
        #get :settings
        #assert(!assigns(:show_year_in_school))
      #end
    #end
  #end

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

  should "get index" do
    get :index
    assert_response :success
  end

  should "get show" do
    xhr :get, :show, { :id => @request.session[:current_organization_id] }
    assert_not_nil assigns(:organization)
  end

  should "get edit" do
    get :edit, { :id => @request.session[:current_organization_id] }
    assert_not_nil assigns(:organization)
  end

  should "get new" do
    get :new
    assert_not_nil assigns(:organization)
    assert_template 'layouts/splash'
  end

  should "get thanks" do
    get :thanks
    assert_template 'layouts/splash'
  end

  should "not save when bad params" do
    post :signup, organization: { :name => "wat" }
    assert_template 'layouts/splash'
  end

  should "redirect on save with good parameters" do
    post :signup, organization: { :name => "wat", :terminology => "wat" }
    assert_response :redirect
  end

  should "get organizations when searching" do
    org1 = Factory(:organization, parent: @org, name: "Test2")
    org2 = Factory(:organization, parent: @org, name: "Test1")

    xhr :get, :search, { :q => "Test" }
    assert_not_nil assigns(:organizations)
    assert_not_nil assigns(:total)

    assert assigns(:organizations).include? org1
    assert assigns(:organizations).include? org2
  end

  should "create org" do
    xhr :post, :create, organization: { :name => "Wat", :terminology => "Wat", :parent_id => @org.id }
    assert_not_nil assigns(:parent)
    assert_not_nil assigns(:organization)
  end

  context "Archiving Contacts" do
    setup do
      @contact1 = Factory(:person)
      Factory(:organizational_role, organization: @org, person: @contact1, role: Role.contact)
      @contact2 = Factory(:person)
      Factory(:organizational_role, organization: @org, person: @contact2, role: Role.contact)
      @contact3 = Factory(:person)
      Factory(:organizational_role, organization: @org, person: @contact3, role: Role.contact)
    end

    should "redirect to cleanup page" do
      xhr :get, :cleanup
      assert_response :success
    end

    should "archive contacts" do
      post :archive_contacts, { :archive_contacts_before => Date.today.strftime("%m-%d-%Y") }
      assert_equal @org.people.archived(@org.id).count, 3
    end

    should "not delete contact roles" do
      assert_no_difference('OrganizationalRole.count') do
        post :archive_contacts, { :archive_contacts_before => Date.today.strftime("%m-%d-%Y") }
      end
    end

    should "archive contacts with the chosen time" do
      #deliberately change the create date of @contact3 contact role
      @contact3.organizational_roles.where(role_id: Role::CONTACT_ID).first.update_attributes({created_at: (Date.today+5).strftime("%Y-%m-%d")})
      post :archive_contacts, { :archive_contacts_before => Date.today.strftime("%m-%d-%Y") }
      assert_equal @org.people.archived(@org.id).count, 2
    end

    should "not include contacts in archive with some roles not yet archived" do
      #deliberately add a non-contact role to @contact 3
      Factory(:organizational_role, organization: @org, person: @contact3, role: Role.involved)
      post :archive_contacts, { :archive_contacts_before => Date.today.strftime("%m-%d-%Y") }
      #only 2 contacts will be included in archived since @contact3 has 2 roles and contact is the only role archived
      assert_equal @org.people.archived(@org.id).count, 2
    end

    should "redirect to cleanup page when there were no contacts archived" do
      post :archive_contacts, { :archive_contacts_before => (Date.today-30).strftime("%m-%d-%Y") }
      assert_equal @org.people.archived(@org.id).count, 0
      assert_redirected_to cleanup_organizations_path
    end

  end

  context "Archiving leaders" do
    setup do
      @leader1 = Factory(:user_with_auxs)
      Factory(:organizational_role, organization: @org, person: @leader1.person, role: Role.leader)
      @leader2 = Factory(:user_with_auxs)
      Factory(:organizational_role, organization: @org, person: @leader2.person, role: Role.leader)
      @leader3 = Factory(:user_with_auxs)
      Factory(:organizational_role, organization: @org, person: @leader3.person, role: Role.leader)
    end

    should "archive leaders" do
      post :archive_leaders, { :date_leaders_not_logged_in_after => Date.today.strftime("%m-%d-%Y") }
      assert_equal @org.people.archived(@org.id).count, 3

    end

    should "not delete leader roles" do
      assert_no_difference('OrganizationalRole.count') do
        post :archive_leaders, { :date_leaders_not_logged_in_after => Date.today.strftime("%m-%d-%Y") }
      end
    end

    should "not include leaders in archive with some roles not yet archived" do
      #deliberately add a non-contact role to @contact 3
      #@leader2.update_attributes({current_sign_in_at: Date.today})
      Factory(:organizational_role, organization: @org, person: @leader2.person, role: Role.involved)
      post :archive_leaders, { :date_leaders_not_logged_in_after => Date.today.strftime("%m-%d-%Y") }
      #only 2 contacts will be included in archived since @contact3 has 2 roles and contact is the only role archived
      assert_equal @org.people.archived(@org.id).count, 2
    end

    should "redirect to cleanup page when there were no leaders archived" do
      post :archive_leaders, { :date_leaders_not_logged_in_after => (Date.today-30).strftime("%m-%d-%Y") }
      assert_equal @org.people.archived(@org.id).count, 0
      assert_redirected_to cleanup_organizations_path
    end
  end

  context "100% Sent feature" do
    setup do
      @user, @organization = admin_user_login_with_org
      @sent_org = Factory(:organization, id: 6816, name: '100% Sent Team')
      @contact1 = Factory(:person, first_name: 'abby')
      @contact2 = Factory(:person, first_name: 'belly')
      @contact3 = Factory(:person, first_name: 'cassy')
      @contact4 = Factory(:person, first_name: 'daisy')
      @contact5 = Factory(:person, first_name: 'elssy')
      Factory(:organizational_role, person: @contact1, role: Role.sent, organization: @org)
      Factory(:organizational_role, person: @contact2, role: Role.sent, organization: @org)
      Factory(:organizational_role, person: @contact3, role: Role.contact, organization: @org)
      Factory(:organizational_role, person: @contact4, role: Role.contact, organization: @org)
      Factory(:organizational_role, person: @contact5, role: Role.contact, organization: @org)
      Factory(:sent_person, person: @contact3)
    end
    should "suggest available contacts when adding contacts to 100% Sent pending list" do
      xhr :get, :available_for_transfer, {term: 's', format: 'js'}
      assert assigns(:people).include?(@contact4), "contact should be suggested"
      assert assigns(:people).include?(@contact5), "contact should be suggested"
      assert_equal false, assigns(:people).include?(@contact3), "contact should not be suggested"
      assert_equal 2, assigns(:people).count, "2 contacts should be suggested"
    end
    should "add contact to transfer queue" do
      assert_equal false, @organization.pending_transfer.include?(@contact3), "contact should not be in the list yet"
      xhr :get, :queue_transfer, {person_id: @contact4.id, format: 'js'}
      assert @organization.pending_transfer.include?(@contact4), "contact should be in the list"
    end
    should "display all pending contacts for transfer" do
      get :transfer
      assert_equal @organization.pending_transfer.count, assigns(:pending_transfer).count
    end
    should "transfer checked contacts" do
      post :do_transfer, {ids: [@contact4.id, @contact5.id]}
      assert assigns(:sent_team_org) == @sent_org, "transfer destination should be 100% Sent Team"
      assert @sent_org.all_people.include?(@contact4), "contact should be transferred"
      assert @sent_org.all_people.include?(@contact5), "contact should be transferred"
      assert SentPerson.find_by_person_id(@contact4.id), "contact should be marked as sent"
      assert SentPerson.find_by_person_id(@contact5.id), "contact should be marked as sent"
    end
    should "transfer checked contacts and mark contacts as alumni" do
      post :do_transfer, {ids: [@contact4.id], tag_as_alumni: '1'}
      assert OrganizationalRole.exists?(role_id: Role::ALUMNI_ID, person_id: @contact4.id, organization_id: @sent_org.id), "contact should have an alumni role"
    end
    should "transfer checked contacts and mark contacts as alumni" do
      post :do_transfer, {ids: [@contact5.id], tag_as_archived: '1'}
      contact_role = OrganizationalRole.find_by_role_id_and_person_id_and_organization_id(Role::CONTACT_ID, @contact5.id, @organization.id)
      assert contact_role.archive_date != nil, "old contact should be archived"
    end
  end



end
