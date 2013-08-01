require 'test_helper'

class InteractionsControllerTest < ActionController::TestCase
  context "Viewing a profile" do
    setup do
      @user, @org = admin_user_login_with_org
      @other_org = Factory(:organization)

      @contact1 = Factory(:person, first_name: "Contact", last_name: "One")
      @contact2 = Factory(:person, first_name: "Contact", last_name: "Two")
      @contact3 = Factory(:person, first_name: "Contact", last_name: "Three")

      Factory(:organizational_permission, organization: @org, person: @contact1, permission: Permission.no_permissions)
      Factory(:organizational_permission, organization: @other_org, person: @contact2, permission: Permission.no_permissions)
      Factory(:organizational_permission, organization: @org, person: @contact3, permission: Permission.admin)
    end

    should "show a person" do
      xhr :get, :show_profile, {:id => @contact1.id}
      assert_response :success
      assert_equal @contact1, assigns(:person)
    end



    should "load the leaders whom person is assigned to" do
      Factory(:contact_assignment, organization: @org, assigned_to: @user.person, person: @person1)

      xhr :get, :show_profile, {id: @contact1.id}
      assert_not_nil assigns(:assigned_tos), assigns(:assigned_tos).inspect
    end



    context "displaying a person's friends in their profile" do
      setup do
        @person = Factory(:person_with_facebook_data)
        @person1 = Factory(:person, fb_uid: 3248973)
        @person2 = Factory(:person, fb_uid: 3343484)
        #add them in the org
        @org.add_contact(@person)
        @org.add_contact(@person1)
        @org.add_contact(@person2)
      end

      should "return the friends who are members of the same org as person" do
        friend1 = Friend.new(@person1.fb_uid, @person1.name, @person)
        friend2 = Friend.new(@person2.fb_uid, @person1.name, @person)

        xhr :get, :show_profile, {id: @person.id }
        org_friends = assigns(:friends)
        assert_not_nil(org_friends)
        assert(org_friends.include?(@person1),"should include person1")
        assert(org_friends.include?(@person2),"should include person2")
        assert_equal(2, org_friends.length)
      end
    end

    should "not show a person from other_org" do
      xhr :get, :show_profile, {:id => @contact2.id}
      assert_response :redirect
    end

    should "show a current person even when current org is sub org" do
      @sub_org = Factory(:organization, ancestry: @org.id)
      @request.session[:current_organization_id] = @sub_org.id
      xhr :get, :show_profile, {:id => @user.person.id}
      assert_response :success
      assert_equal @user.person, assigns(:person)
    end
  end

  context "Updating followup status" do
    setup do
      @user, @org = admin_user_login_with_org
      @other_org = Factory(:organization)

      @contact1 = Factory(:person, first_name: "Contact", last_name: "One")
      @contact2 = Factory(:person, first_name: "Contact", last_name: "Two")
      @admin1 = Factory(:person, first_name: "Admin", last_name: "One")

      Factory(:organizational_permission, organization: @org, person: @contact1, permission: Permission.no_permissions, followup_status: 'uncontacted')
      Factory(:organizational_permission, organization: @other_org, person: @contact2, permission: Permission.no_permissions, followup_status: 'uncontacted')
      Factory(:organizational_permission, organization: @org, person: @admin1, permission: Permission.admin, followup_status: nil)
    end

    should "successfully update a contact's followup status" do
      xhr :get, :change_followup_status, {:person_id => @contact1.id, :status => 'contacted'}
      assert_response :success
      contact_permission = OrganizationalPermission.find_by_person_id_and_organization_id(@contact1.id, @org.id)
      assert_equal 'contacted', contact_permission.followup_status
    end

    should "not update a the followup status of non-contact person" do
      xhr :get, :change_followup_status, {:person_id => @admin1.id, :status => 'contacted'}
      assert_response :success
      admin_permission = OrganizationalPermission.find_by_person_id_and_organization_id(@admin1.id, @org.id)
      assert_nil admin_permission.followup_status
    end

    should "not update a the followup status of contact from other org" do
      xhr :get, :change_followup_status, {:person_id => @contact2.id, :status => 'contacted'}
      assert_response :success
      contact_permission = OrganizationalPermission.find_by_person_id_and_organization_id(@contact2.id, @other_org.id)
      assert_equal 'uncontacted', contact_permission.followup_status
    end
  end

end
