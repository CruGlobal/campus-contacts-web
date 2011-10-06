require 'test_helper'

class ContactAssignmentsControllerTest < ActionController::TestCase
  context "After logging in a person with orgs" do
    setup do
      #@user = Factory(:user)
      @user = Factory(:user_with_auxs)  #user with a person object
      @current_organization = @user.person.organizations.first
      sign_in @user
    end
    
    context "bulk assign" do
      setup do
        @contact1 = Factory(:person)
        @contact2 = Factory(:person)
        
        @user.person.organizations.first.add_contact(@contact1)
        @user.person.organizations.first.add_contact(@contact2)        
        
        assert_not_nil OrganizationalRole.where(person_id: @contact1, organization_id: @current_organization, role_id: Role::CONTACT_ID)
        assert_not_nil OrganizationalRole.where(person_id: @contact2, organization_id: @current_organization, role_id: Role::CONTACT_ID)
      end
      
      should "should move the contact to do not contact" do
        xhr :post, :create, { :assign_to => "do_not_contact", :ids => [@contact1, @contact2], :org_id => @current_organization }        

        assert_equal 0, ContactAssignment.where(person_id: @contact1, organization_id: @current_organization).size
        assert_equal 0, ContactAssignment.where(person_id: @contact2, organization_id: @current_organization).size        
        assert_equal "do_not_contact", OrganizationalRole.where(person_id: @contact1, organization_id: @current_organization, role_id: Role::CONTACT_ID).first.followup_status
        assert_equal "do_not_contact", OrganizationalRole.where(person_id: @contact2, organization_id: @current_organization, role_id: Role::CONTACT_ID).first.followup_status
      end
      
    end
    
  end
  
      
end
