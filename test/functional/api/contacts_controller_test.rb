require 'test_helper'

class Api::ContactsControllerTest < ActionController::TestCase
  include ApiTestHelper
  
  context "API v1" do
    setup do
      setup_api_env
      
      request.env['HTTP_ACCEPT'] = 'application/vnd.missionhub-v1+json'
      request.env['oauth.access_token'] = @access_token3.code 
    end
    
    should "be able to view their contacts" do 
      
      get :index
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
      get :index, {filters: 'gender', values: 'male'}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json.length,2)
      @json.each do |person|
        assert_equal(person['person']['gender'],'Male')
        assert_not_equal(person['person']['gender'],'Female')
      end
    end
    
    #make sure filtering works
    should "be able to view their contacts filtered by gender=female" do
      get :index, {filters: 'gender', values: 'female'}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json.length,0)
      
      @user.person.update_attributes(gender: 'Female')
      @user2.person.update_attributes(gender: 'Female')
      get :index, {filters: 'gender', values: 'female'}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json.length,2)
      @json.each do |person|
        assert_equal(person['person']['gender'],'Female')
        assert_not_equal(person['person']['gender'],'Male')
      end
    end
    
    should "be able to view their contacts with limit" do
      get :index, {limit: '1'}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
    
      assert_equal(1, @json.length)
    end
      
    should "be able to view their contacts with start and limit" do
      get :index, {limit: '1', start: '1'} 
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
    
      assert_equal(1, @json.length)   
    end
    
    
    should 'raise an error when no limit with start' do
      get :index, {start: '1'} 
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      
      assert_equal("29", @json['error']['code'])
    end
    
    context "When filtering contacts by status" do
      should "be able to view contacted with org id" do
        @user2.person.organizational_roles.first.update_attributes!(role_id: Role::CONTACT_ID, followup_status: "contacted")
        get :index, {"filters"=>"status", "values"=>"contacted", "org_id"=> @user3.person.primary_organization.id}
        assert_response :success, @response.body
        @json = ActiveSupport::JSON.decode(@response.body)
      
        assert_equal(1, @json.length)
        person_basic_test(@json[0]['person'],@user2,@user)
      end  
    
      should "be able to view contacted without org id" do
        @user.person.organizational_roles.first.update_attributes!(followup_status: "attempted_contact", role_id: Role::CONTACT_ID)
        @user2.person.organizational_roles.first.update_attributes!(followup_status: "attempted_contact", role_id: Role::CONTACT_ID)
        get :index, {"filters"=>"status", "values"=>"contacted"}
        assert_response :success, @response.body
        @json = ActiveSupport::JSON.decode(@response.body)
        assert_equal(0, @json.length)
      end
      
      should "be able to view attempted_contact" do
        @user.person.organizational_roles.first.update_attributes!(followup_status: "attempted_contact", role_id: Role::CONTACT_ID)
        @user2.person.organizational_roles.first.update_attributes!(followup_status: "attempted_contact", role_id: Role::CONTACT_ID)
        get :index, {"filters"=>"status", "values"=>"attempted_contact"}
        assert_response :success, @response.body
        @json = ActiveSupport::JSON.decode(@response.body)
        assert_equal(2, @json.length)
      end
      
      should "be able to filter by more than one criteria" do
        @user.person.organizational_roles.first.update_attributes!(followup_status: "attempted_contact", role_id: Role::CONTACT_ID)
        @user2.person.organizational_roles.first.update_attributes!(followup_status: "attempted_contact", role_id: Role::CONTACT_ID)
      
        get :index, {"filters"=>"status,gender", "values"=>"attempted_contact,female"}
        assert_response :success, @response.body
        @json = ActiveSupport::JSON.decode(@response.body)
        assert_equal(0, @json.length)
      end
      
      should "be able to use filter and sort by status" do
        @user.person.organizational_roles.first.update_attributes!(followup_status: "attempted_contact", role_id: Role::CONTACT_ID)
        @user2.person.organizational_roles.first.update_attributes!(followup_status: "attempted_contact", role_id: Role::CONTACT_ID)
        get :index, {"filters"=>"status", "values"=>"attempted_contact", "sort"=>"status", "direction"=>"asc"}
        assert_response :success, @response.body
        @json = ActiveSupport::JSON.decode(@response.body)
        assert_equal(2, @json.length)
      end
    end
    
    should "not make the iPhone contacts category queries fail" do
      # contacts assigned to me (My contacts) on mobile app
      @user2.person.organizational_roles.first.update_attributes(followup_status: 'completed')
      @contact_assignment2.destroy
      ContactAssignment.create(assigned_to_id:@user3.person.id, person_id: @user.person.id, organization_id: @user3.person.primary_organization.id)
    
      get :index, {"filters"=>"status", "values"=>"not_finished", "assigned_to"=> @user3.person.id, "limit"=>"15", "start"=>"0", "org_id"=>@user3.person.primary_organization.id}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
    
      assert_equal(1, @json.length)
      assert_equal(@json[0]['person']['id'], @user.person.id)
    end
    
    should "show my completed contacts" do
      @user2.person.organizational_roles.first.update_attributes(followup_status: 'uncontacted')
      get :index, {"filters"=>"status", "values"=>"finished", "assigned_to"=>@user.person.id, "limit"=>"15", "start"=>"0", "org_id"=> @user3.person.primary_organization.id}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(0, @json.length)
    
      @user2.person.organizational_roles.where(organization_id: @user3.person.primary_organization.id).first.update_attributes(followup_status: 'completed')
      get :index, {"filters"=>"status", "values"=>"finished", "assigned_to"=> @user.person.id, "limit"=>"15", "start"=>"0", "org_id"=> @user3.person.primary_organization.id}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(1, @json.length)
      assert_equal(@json[0]['person']['id'], @user2.person.id)
    end
    
    should "show my unassigned contacts" do
      @user.person.organizational_roles.where(organization_id: @user3.person.primary_organization.id).first.update_attributes(followup_status: 'uncontacted')      
      get :index, {"filters"=>"status", "values"=>"not_finished", "assigned_to"=>"none", "limit"=>"15", "start"=>"0", "org_id"=> @user3.person.primary_organization.id} 
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json.length,0)

      ContactAssignment.destroy_all
      @user.person.organizational_roles.first.update_attributes(followup_status: 'uncontacted')
      get :index, {"filters"=>"status", "values"=>"not_finished", "assigned_to"=>"none", "limit"=>"15", "start"=>"0", "org_id"=> @user3.person.primary_organization.id} 
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
          
      assert_equal(@json.length,2)
    end
    
    
    should "be able to view their contacts with sorting" do
      @user2.person.organizational_roles.first.update_attributes(created_at: 2.days.ago)
      get :index, {"sort"=>"time", "direction"=>"desc"}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      
      assert_equal(@json.length, 2)
      person_mini_test(@json[0]['person'],@user) 
    
      @user2.person.organizational_roles.first.update_attributes(created_at: 2.days.ago)
      get :index, {"sort"=>"time", "direction"=>"asc"}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json.length, 2)
      person_mini_test(@json[0]['person'],@user2)
    end
    # 
    should "be able to view their contacts by searching" do
      get :search, :term => 'Useroo'
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
    
      person_basic_test(@json[0]['person'], @user2, @user)
    end

    should "show a contact" do
      get :show, :id => @user2.person.id
      assert_response :success, @response.body
    end
  end
end
