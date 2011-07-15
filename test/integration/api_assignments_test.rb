require 'test_helper'
include ApiTestHelper

class ApiAssignmentsTest < ActionDispatch::IntegrationTest
  context "the api" do
    setup do
      setup_api_env()
    end
    
   should "be able to create a contact assignment" do 
      path = "/api/contact_assignments/"
      ContactAssignment.destroy_all
      post path, {'access_token' => @access_token3.code, org_id: @user3.person.primary_organization.id, assign_to: @user2.person.id, ids: @user2.person.id}
      assert_equal(@user2.person.contact_assignments.count, 1)
    end

    should "fail to create a contact assignment" do 
      path = "/api/contact_assignments/"
      ContactAssignment.destroy_all
      post path, {'access_token' => @access_token3.code, org_id: @user3.person.primary_organization.id, assign_to: "23423523a", ids: @user2.person.id}
      @json = ActiveSupport::JSON.decode(@response.body)      
      assert_equal(@json['error']['code'], '27')

      ContactAssignment.destroy_all
      post path, {'access_token' => @access_token3.code, org_id: '234abc', assign_to: "23423523", ids: @user2.person.id}
      @json = ActiveSupport::JSON.decode(@response.body)      
      assert_equal(@json['error']['code'], '30')
    end

    should "be able to delete a contact assignment" do 
      ContactAssignment.destroy_all
      y = ContactAssignment.create(organization_id: @user3.person.primary_organization.id, person_id: @user.person.id, assigned_to_id: @user.person.id)
      assert_equal(@user.person.contact_assignments.count, 1)
      path = "/api/contact_assignments/#{@user.person.id}"
      delete path, {'access_token' => @access_token3.code}
      assert_equal(@user.person.contact_assignments.count, 0)
    end
    
    should "raise a json exception when deleting a contact assignment without the contact_assignment scope" do
      path = "/api/contact_assignments/#{@user.person.id}"
      @access_token3.update_attributes(scope: "contacts userinfo followup_comments")
      delete path, {'access_token' => @access_token3.code}
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json['error']['code'],"55")
    end
  end
end