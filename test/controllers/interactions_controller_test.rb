require 'test_helper'

class InteractionsControllerTest < ActionController::TestCase
  context 'Updating followup status' do
    setup do
      @user, @org = admin_user_login_with_org
      @other_org = FactoryGirl.create(:organization)

      @contact1 = FactoryGirl.create(:person, first_name: 'Contact', last_name: 'One')
      @contact2 = FactoryGirl.create(:person, first_name: 'Contact', last_name: 'Two')
      @admin1 = FactoryGirl.create(:person, first_name: 'Admin', last_name: 'One')

      FactoryGirl.create(:organizational_permission, organization: @org, person: @contact1, permission: Permission.no_permissions, followup_status: 'uncontacted')
      FactoryGirl.create(:organizational_permission, organization: @other_org, person: @contact2, permission: Permission.no_permissions, followup_status: 'uncontacted')
      FactoryGirl.create(:organizational_permission, organization: @org, person: @admin1, permission: Permission.admin, followup_status: nil)
    end

    should "successfully update a contact's followup status" do
      xhr :get, :change_followup_status, person_id: @contact1.id, status: 'contacted'
      assert_response :success
      contact_permission = OrganizationalPermission.find_by_person_id_and_organization_id(@contact1.id, @org.id)
      assert_equal 'contacted', contact_permission.followup_status
    end

    should 'not update a the followup status of non-contact person' do
      xhr :get, :change_followup_status, person_id: @admin1.id, status: 'contacted'
      assert_response :success
      admin_permission = OrganizationalPermission.find_by_person_id_and_organization_id(@admin1.id, @org.id)
      assert_nil admin_permission.followup_status
    end

    should 'not update a the followup status of contact from other org' do
      xhr :get, :change_followup_status, person_id: @contact2.id, status: 'contacted'
      assert_response :success
      contact_permission = OrganizationalPermission.find_by_person_id_and_organization_id(@contact2.id, @other_org.id)
      assert_equal 'uncontacted', contact_permission.followup_status
    end
  end
end
