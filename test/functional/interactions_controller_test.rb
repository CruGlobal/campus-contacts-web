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

    should "not show a person from other_org" do
      xhr :get, :show_profile, {:id => @contact2.id}
      assert_response :redirect
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
