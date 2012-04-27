require 'test_helper'

class ContactAssignmentsControllerTest < ActionController::TestCase
  
  context "Assigning contacts" do
    setup do
      @user, @org = admin_user_login_with_org
    end
    
    should "bulk assign contacts" do
      contact1 = Factory(:person)
      contact2 = Factory(:person)
      
      @org.add_contact(contact1)
      @org.add_contact(contact2)
      
      assert_equal 0, ContactAssignment.count
      
      xhr :post, :create, { :assign_to => @user.person.id, :ids => [contact1, contact2], :org_id => @org.id }
      
      assert_equal 2, ContactAssignment.count
      
      assert_not_nil OrganizationalRole.where(person_id: contact1.id, organization_id: @org.id, role_id: Role::CONTACT_ID)
      assert_equal "uncontacted", OrganizationalRole.where(person_id: contact1.id, organization_id: @org.id, role_id: Role::CONTACT_ID).first.followup_status
      assert_not_nil OrganizationalRole.where(person_id: contact2.id, organization_id: @org.id, role_id: Role::CONTACT_ID)
      assert_equal "uncontacted", OrganizationalRole.where(person_id: contact2.id, organization_id: @org.id, role_id: Role::CONTACT_ID).first.followup_status
    end
    
    should "raise RecordNotUnique error when the same user is assigned" do
      contact1 = Factory(:person)
      
      assert_raises ActiveRecord::RecordNotUnique do
        xhr :post, :create, { :assign_to => @user.person.id, :ids => [contact1, contact1], :org_id => @org.id }
      end
    end
    
    should "assign to do not contact" do
      contact1 = Factory(:person)
      contact2 = Factory(:person)
      
      @org.add_contact(contact1)
      @org.add_contact(contact2)
      
      xhr :post, :create, { :assign_to => "do_not_contact", :ids => [contact1, contact2], :org_id => @org.id }        

      assert_equal 0, ContactAssignment.where(person_id: contact1.id, organization_id: @org.id).size
      assert_equal 0, ContactAssignment.where(person_id: contact2.id, organization_id: @org.id).size        
      assert_equal "do_not_contact", OrganizationalRole.where(person_id: contact1.id, organization_id: @org.id, role_id: Role::CONTACT_ID).first.followup_status
      assert_equal "do_not_contact", OrganizationalRole.where(person_id: contact2.id, organization_id: @org.id, role_id: Role::CONTACT_ID).first.followup_status
      
      assert assigns(:reload_sidebar)
    end
    
  end
      
end
