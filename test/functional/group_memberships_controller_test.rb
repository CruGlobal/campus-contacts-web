require 'test_helper'

class GroupMembershipsControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  context "Assigning people to groups" do
    setup do
      @person1 = Factory(:person)
      @person2 = Factory(:person)
      @person3 = Factory(:person)
      @person4 = Factory(:person)
      
      user = Factory(:user_with_auxs)
      sign_in user
      org = Factory(:organization)
      org.add_admin(user.person)
      
      @group = Factory(:group, organization: org)
      request.session[:current_organization_id] = org.id 
    end
    
    should "properly assign a single user to a group" do
      post :create, { :group_id => @group.id, :person_id => @person1.id.to_s, :role => "member" }
      assert_equal(@group.members.count, 1, "must return correct number of members.")
      assert(@group.members.include?(@person1), "person must be assigned to group")
    end
    
    should "properly assign multiple users to a group" do
      person_ids = "#{@person1.id},#{@person2.id},#{@person3.id},#{@person4.id}"
      post :create, { :group_id => @group.id, :person_id => person_ids, :role => "member" }
      assert_equal(@group.members.count, 4, "must return correct number of members.")
      assert(@group.members.include?(@person1), "person must be assigned to group")
      assert(@group.members.include?(@person2), "person must be assigned to group")
      assert(@group.members.include?(@person3), "person must be assigned to group")
      assert(@group.members.include?(@person4), "person must be assigned to group")
    end
  end
end
