require 'test_helper'

class ContactAssignmentsControllerTest < ActionController::TestCase

  context "Assigning contacts" do
    setup do
      @user, @org = admin_user_login_with_org
    end

    should "bulk assign contacts" do
      contact1 = FactoryGirl.create(:person)
      contact2 = FactoryGirl.create(:person)

      @org.add_contact(contact1)
      @org.add_contact(contact2)

      assert_equal 0, ContactAssignment.count

      xhr :post, :create, { :assign_to => @user.person.id, :ids => [contact1, contact2], :org_id => @org.id }

      assert_equal 2, ContactAssignment.count

      assert_not_nil OrganizationalPermission.where(person_id: contact1.id, organization_id: @org.id, permission_id: Permission::NO_PERMISSIONS_ID)
      assert_equal "uncontacted", OrganizationalPermission.where(person_id: contact1.id, organization_id: @org.id, permission_id: Permission::NO_PERMISSIONS_ID).first.followup_status
      assert_not_nil OrganizationalPermission.where(person_id: contact2.id, organization_id: @org.id, permission_id: Permission::NO_PERMISSIONS_ID)
      assert_equal "uncontacted", OrganizationalPermission.where(person_id: contact2.id, organization_id: @org.id, permission_id: Permission::NO_PERMISSIONS_ID).first.followup_status
    end

    should "no new ContactAssignment created when rescued from RecordNotUnique error" do
      contact1 = FactoryGirl.create(:person)
      FactoryGirl.create(:contact_assignment, organization: @org, assigned_to: @user.person, person: contact1)

      assert_no_difference "ContactAssignment.count" do
        xhr :post, :create, { :assign_to => @user.person.id, :ids => [contact1.id], :org_id => @org.id }
      end
    end

    should "assign to leader if followup status is 'do not contact'" do
      contact1 = FactoryGirl.create(:person)
      contact2 = FactoryGirl.create(:person)

      FactoryGirl.create(:organizational_permission, person: contact1, organization: @org, permission: Permission.no_permissions).update_attributes({followup_status: "do_not_contact"})
      FactoryGirl.create(:organizational_permission, person: contact2, organization: @org, permission: Permission.no_permissions).update_attributes({followup_status: "do_not_contact"})

      xhr :post, :create, { :assign_to => @user.person.id, :ids => [contact1.id, contact2.id], :org_id => @org.id }
    end

    should "assign to do not contact" do
      contact1 = FactoryGirl.create(:person)
      contact2 = FactoryGirl.create(:person)

      @org.add_contact(contact1)
      @org.add_contact(contact2)

      xhr :post, :create, { :assign_to => "do_not_contact", :ids => [contact1, contact2], :org_id => @org.id }

      assert_equal 0, ContactAssignment.where(person_id: contact1.id, organization_id: @org.id).size
      assert_equal 0, ContactAssignment.where(person_id: contact2.id, organization_id: @org.id).size
      assert_equal "do_not_contact", OrganizationalPermission.where(person_id: contact1.id, organization_id: @org.id, permission_id: Permission::NO_PERMISSIONS_ID).first.followup_status
      assert_equal "do_not_contact", OrganizationalPermission.where(person_id: contact2.id, organization_id: @org.id, permission_id: Permission::NO_PERMISSIONS_ID).first.followup_status

      assert assigns(:reload_sidebar)
    end

    should "not raise error when the permission of an ID does not exist" do
      contact1 = FactoryGirl.create(:person)
      contact2 = FactoryGirl.create(:person)

      @org.add_contact(contact1)

      xhr :post, :create, { :assign_to => "do_not_contact", :ids => [contact1, contact2], :org_id => @org.id }

      assert_nil ContactAssignment.find_by_person_id_and_organization_id(contact1.id, @org.id)
      assert_nil OrganizationalPermission.find_by_person_id_and_organization_id_and_permission_id(contact2.id, @org.id, Permission::NO_PERMISSIONS_ID)
      assert_equal "do_not_contact", OrganizationalPermission.find_by_person_id_and_organization_id_and_permission_id(contact1.id, @org.id, Permission::NO_PERMISSIONS_ID).followup_status
      assert assigns(:reload_sidebar)
    end

  end

end
