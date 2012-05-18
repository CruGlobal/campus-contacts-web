require 'test_helper'

class OrganizationalRolesControllerTest < ActionController::TestCase
  context "Updating contacts" do
    setup do
      @user, @org = admin_user_login_with_org
      
      @org_role = Factory(:organizational_role)
    end
    
    should "update organizational role" do
      xhr :put, :update, { :id => @org_role.id, :status => "" }
      assert_response :success
      assert_not_nil assigns(:organizational_role)
      assert_equal OrganizationalRole.find(@org_role.id), assigns(:organizational_role)
    end
  end
  
  context "Moving contacts" do
    setup do
      @user, @org = admin_user_login_with_org
      
      @person1 = Factory(:person)
      @person2 = Factory(:person)
      @person3 = Factory(:person)
      
      @another_org = Factory(:organization)
    end
    
    should "move the people from one org to another org" do
      @org.add_contact(@person1)
      @org.add_contact(@person2)
      @org.add_contact(@person3)
      
      ids = []
      ids << @person1.id
      ids << @person2.id
      ids << @person3.id
      
      xhr :post, :move_to, { :from_id => @org.id , :to_id => @another_org.id, :ids => ids, :keep_contact => true, :current_admin => @user }
      assert @org.contacts.include? @person1
      assert @another_org.contacts.include? @person1
    end
  end
end
