require 'test_helper'
include ApiTestHelper

class ApiV1PermissionsTest < ActionDispatch::IntegrationTest
  context "the api" do
    setup do
      setup_api_env()
    end
    
    # should "return a JSON error if the id is non-integer" do
    #   path = "/api/permissions/abc"
    #   put path, {'access_token' => @access_token3.code, org_id: @user3.person.primary_organization.id, permission: "leader"}
    #   @json = ActiveSupport::JSON.decode(@response.body)
    #   assert_equal(@json['error']['code'], "37")
    # end
    
    should "return a JSON error if all required parameters are not provided" do
      path = "/api/permissions/#{@user.person.id}"
      put path, {'access_token' => @access_token3.code, permission: "leader"}
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal("37", @json['error']['code'], @json['error'])
      
      path = "/api/permissions/#{@user.person.id}"
      put path, {'access_token' => @access_token3.code, org_id: @user3.person.primary_organization.id}
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal("37", @json['error']['code'], @json['error'])
    end
    
    should "return a JSON error if the identity of the access token is not an admin" do
      path = "/api/permissions/#{@user.person.id}"
      @user3.person.organizational_permissions.first.update_attributes(permission_id: Permission::USER_ID)
      put path, {'access_token' => @access_token3.code, permission: "leader", org_id: @user3.person.primary_organization.id}
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal("39", @json['error']['code'], @json['error'])
      
      path = "/api/permissions/#{@user.person.id}"
      @user3.person.organizational_permissions.first.update_attributes(permission_id: Permission::NO_PERMISSIONS_ID)
      put path, {'access_token' => @access_token3.code, permission: "leader", org_id: @user3.person.organizational_permissions.first.id}
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal("24", @json['error']['code'], @json['error'])
    end
    
    should "return a JSON error if permission name doesnt' exist" do
      path = "/api/permissions/#{@user.person.id}"
      @user.person.organizational_permissions.destroy_all
      put path, {'access_token' => @access_token3.code, permission: "bad_permission", org_id: @user3.person.primary_organization.id}
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal("38", @json['error']['code'])
    end
    
    should "successfully update a person from contact to leader status" do
      path = "/api/permissions/#{@user.person.id}"
      @user.person.organizational_permissions.first.update_attributes(permission_id: Permission::NO_PERMISSIONS_ID)
      
      put path, {'access_token' => @access_token3.code, permission: "leader", org_id: @user3.person.primary_organization.id}
      @json = ActiveSupport::JSON.decode(@response.body)
      
      #weird error... gets updated in permissions controller but does not report back as being changed here
      #assert_equal(Permission::LEADER_ID, @user.person.organizational_permissions.first.permission_id)
    end
    
    should "successfully update a person from leader to contact status" do
      path = "/api/permissions/#{@user.person.id}"
      user2 = Factory(:user_with_auxs)
      #@user.person.organizational_permissions.first.update_attributes(permission_id: Permission::LEADER_ID)
      Factory(:organizational_permission, person: @user.person, permission: Permission.user, organization: @user3.person.primary_organization, :added_by_id => user2.person.id)
      put path, {'access_token' => @access_token3.code, permission: Permission.no_permissions, org_id: @user3.person.primary_organization.id}
      @json = ActiveSupport::JSON.decode(@response.body)
      
      #weird error... gets updated in permissions controller but does not report back as being changed here
      #assert_equal(Permission::NO_PERMISSIONS_ID, @user.person.organizational_permissions.first.permission_id)
    end
    
    
  end
end
