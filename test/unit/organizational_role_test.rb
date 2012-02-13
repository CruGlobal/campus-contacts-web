require 'test_helper'

class OrganizationalRoleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  context "Role assignment" do
    setup do
      @person = Factory(:person, email: '')
      @user = Factory(:user_with_auxs, email: 'test@uscm.org')
      @org = Factory(:organization)
    end
    
    should "assert exception" do
      assert_raises OrganizationalRole::InvalidPersonAttributesError do
        Factory(:organizational_role, person: @person, role: Role.leader, organization: @org, :added_by_id => @user.person.id)
      end
    end
  end
end
