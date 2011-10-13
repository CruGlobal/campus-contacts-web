require 'test_helper'
include ApiTestHelper

class ApiContactsTest < ActionDispatch::IntegrationTest
  context "API v1" do
    setup do
      setup_api_env()
    end
    
    should "be able to view their contacts" do
      path = "/api/v1/contacts/"

      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)

      if @json[0]['person']['name'] == "John Doe"
        person_basic_test(@json[0]['person'],@user,@user2)
        person_basic_test(@json[1]['person'],@user2,@user)
      else
        person_basic_test(@json[0]['person'],@user2,@user)
        person_basic_test(@json[1]['person'],@user,@user2)
      end
    end
    
    #make sure that filtering by gender works
    should "be able to view their contacts filtered by gender=male" do
      path = "/api/v1/contacts.json?filters=gender&values=male"
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json.length,2)
      @json.each do |person|
        assert_equal(person['person']['gender'],'male')
        assert_not_equal(person['person']['gender'],'female')
      end
    end
    
    #make sure filtering by female works
    should "be able to view their contacts filtered by gender=female" do
      path = "/api/v1/contacts.json?filters=gender&values=female"
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json.length,0)
      
      @user.person.update_attributes(gender: 'female')
      @user2.person.update_attributes(gender: 'female')
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json.length,2)
      @json.each do |person|
        assert_equal(person['person']['gender'],'female')
        assert_not_equal(person['person']['gender'],'male')
      end
    end
    
    should "be able to view their contacts with start and limit" do
      path = "/api/v1/contacts.json?limit=1&start=0"
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)

      assert_equal(1, @json.length)
      
      path = "/api/v1/contacts.json?limit=1&start=1"
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)

      assert_equal(1, @json.length)   
      
      #raise an error when no limit with start
      path = "/api/v1/contacts.json?start=1"
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      
      assert_equal("29", @json['error']['code'])

      path = "/api/v1/contacts.json?limit=1"
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(1, @json.length)
    end
    
    should "be able to view their contacts filtered by status" do
      @user2.person.organizational_roles.first.update_attributes!(role_id: Role::CONTACT_ID, followup_status: "contacted")
      path = "/api/v1/contacts.json?filters=status&values=contacted&org_id=#{@user3.person.primary_organization.id}"
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      
      assert_equal(1, @json.length)
      person_basic_test(@json[0]['person'],@user2,@user)
      @user.person.organizational_roles.first.update_attributes!(followup_status: "attempted_contact", role_id: Role::CONTACT_ID)
      @user2.person.organizational_roles.first.update_attributes!(followup_status: "attempted_contact", role_id: Role::CONTACT_ID)
      path = "/api/v1/contacts.json?filters=status&values=contacted"
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(0, @json.length)
     
      path = "/api/v1/contacts.json?filters=status&values=attempted_contact"
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(2, @json.length)

      
      path = "/api/v1/contacts.json?filters=status,gender&values=attempted_contact,female"
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(0, @json.length)
      
      # use filter and sort by status
      path = "/api/v1/contacts.json?filters=status&values=attempted_contact&sort=status&direction=asc"
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(2, @json.length)
    end
    
    should "not make the iPhone contacts category queries fail" do
      
      # contacts assigned to me (My contacts) on mobile app
      @user2.person.organizational_roles.first.update_attributes(followup_status: 'completed')
      @contact_assignment2.destroy
      ContactAssignment.create(assigned_to_id:@user3.person.id, person_id: @user.person.id, organization_id: @user3.person.primary_organization.id)

      path = "/api/v1/contacts.json?filters=status&values=not_finished&assigned_to=#{@user3.person.id}&limit=15&start=0&org_id=#{@user3.person.primary_organization.id}"
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)

      assert_equal(1, @json.length)
      assert_equal(@json[0]['person']['id'], @user.person.id)

      # my completed contacts on mobile app
      @user2.person.organizational_roles.first.update_attributes(followup_status: 'uncontacted')
      path = "/api/v1/contacts.json?filters=status&values=finished&assigned_to=#{@user.person.id}&limit=15&start=0&org_id=#{@user3.person.primary_organization.id}"
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(0, @json.length)
      
      @user2.person.organizational_roles.where(organization_id: @user3.person.primary_organization.id).first.update_attributes(followup_status: 'completed')
      path = "/api/v1/contacts.json?filters=status&values=finished&assigned_to=#{@user.person.id}&limit=15&start=0&org_id=#{@user3.person.primary_organization.id}"
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json.length,1)
      assert_equal(@json[0]['person']['id'], @user2.person.id)
      
      @user.person.organizational_roles.where(organization_id: @user3.person.primary_organization.id).first.update_attributes(followup_status: 'uncontacted')      
      path = "/api/v1/contacts.json?filters=status&values=not_finished&assigned_to=none&limit=15&start=0&org_id=#{@user3.person.primary_organization.id}"
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json.length,0)
      
      ContactAssignment.destroy_all
      # unassigned contacts mobile app query
      @user.person.organizational_roles.first.update_attributes(followup_status: 'uncontacted')
      path = "/api/v1/contacts.json?assigned_to=none&filters=status&values=not_finished&limit=15&start=0&org_id=#{@user3.person.primary_organization.id}"
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)

      assert_equal(@json.length,1)  
      assert_equal(@json[0]['person']['id'], @user.person.id)
    end
    
    
    should "be able to view their contacts with sorting" do
      path = "/api/v1/contacts.json?sort=time&direction=desc"
      @user2.person.organizational_roles.first.update_attributes(created_at: 2.days.ago)
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      
      assert_equal(@json.length, 2)
      person_mini_test(@json[0]['person'],@user) 

      path = "/api/v1/contacts.json?sort=time&direction=asc"
      @user2.person.organizational_roles.first.update_attributes(created_at: 2.days.ago)
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json.length, 2)
      person_mini_test(@json[0]['person'],@user2)
    end
    
    should "be able to view their contacts by searching" do
      path = "/api/v1/contacts/search?term=Useroo"
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)

      person_basic_test(@json[0]['person'], @user2, @user)
    end
  end
end