require 'test_helper'

class OrganizationalPermissionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  context "Permission assignment" do
    setup do
      @person = Factory(:person, email: '')
      @user = Factory(:user_with_auxs, email: 'test@uscm.org')
      @org = Factory(:organization)
    end
    
    should "assert exception" do
      assert_raises OrganizationalPermission::InvalidPersonAttributesError do
        Factory(:organizational_permission, person: @person, permission: Permission.user, organization: @org, :added_by_id => @user.person.id)
      end
    end
  end
end
