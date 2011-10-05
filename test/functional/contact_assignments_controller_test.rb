require 'test_helper'

class ContactAssignmentsControllerTest < ActionController::TestCase
  context "After logging in a person with orgs" do
    setup do
      #@user = Factory(:user)
      @user = Factory(:user_with_auxs)  #user with a person object
      sign_in @user
    end
    
    context "bulk assign" do
      setup do
        @contact1 = Factory(:person)
        @contact2 = Factory(:person)
        
        @user.person.organizations.first.add_contact(@contact1)
        @user.person.organizations.first.add_contact(@contact2)        
      end
      
      should "should move the contact to do not contact" do
        xhr :post, :create, { :assign_to => "do_not_contact", :ids => [@contact1.id, @contact2.id], :org_id =>  @user.person.organizations.first.id }        
        # need to assert if @contact1 is really gone from organization        
      end
      
    end
    
  end
  
      
end
