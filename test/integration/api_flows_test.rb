require 'test_helper'

class ApiFlowsTest < ActionDispatch::IntegrationTest

  context "a user" do
    setup do
      @user = Factory.create(:user_with_auxs)
      @user2 = Factory.create(:user2_with_auxs)
      @user2.person.organization_memberships.destroy_all
      @user2.person.organization_memberships.create(:organization_id => @user.person.primary_organization.id, :person_id => @user2.person.id, :primary => 1, :role => "leader", :followup_status => "contacted")
      ContactAssignment.create(:assigned_to_id => @user.person.id, :person_id => @user2.person.id, :organization_id => @user.person.organizations.first.id)
      ContactAssignment.create(:assigned_to_id => @user2.person.id, :person_id => @user.person.id, :organization_id => @user.person.organizations.first.id)
      @access_token = Factory.create(:access_token, :identity => @user.id)
      @access_token2 = Factory.create(:access_token, :identity => @user2.id, :code => "aoeuaocnpganoeuhnh234hnaeu")
    end
    
    should "be able to request user information" do
      path = "/api/people/#{@user.person.id}"
      get path, {'access_token' => @access_token.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json[0]['name'], "John Doe")
      assert_equal(@json[0]['picture'], "http://graph.facebook.com/690860831/picture")
      assert_equal(@json[0]['fb_id'], "690860831")
      assert_equal(@json[0]['first_name'], "John")
      assert_equal(@json[0]['last_name'], "Doe")
      assert_equal(@json[0]['locale'], "")
      assert_equal(@json[0]['birthday'], "1989-12-18")
      assert_equal(@json[0]['education'][0]['school']['name'], "Test High School")
      assert_equal(@json[0]['education'][1]['school']['name'], "Test University")
      assert_equal(@json[0]['education'][2]['school']['name'], "Test University 2")
      assert_equal(@json[0]['interests'][1]['name'], "Test Interest 2")
      assert_equal(@json[0]['gender'], "male")
      assert_equal(@json[0]['id'], @user.person.id)
      assert_equal(@json[0]['status'], "attempted_contact")
      assert_equal(@json[0]['assignment']['assigned_to_person'][0]['id'], @user.person.id)
      assert_equal(@json[0]['assignment']['person_assigned_to'][0]['id'], @user2.person.id)
      assert_equal(@json[0]['request_org_id'], @user.person.primary_organization.id)
      assert_equal(@json[0]['organization_membership'][0]['org_id'], @user.person.primary_organization.id)
      assert_equal(@json[0]['organization_membership'][0]['role'], @user.person.organization_memberships.first.role)
      assert_equal(@json[0]['organization_membership'][0]['primary'].downcase, 'true')
      
    end
    
    should "be able to request user information with fields" do
      #      :people => ["first_name", "last_name", "name", "id", "location", "birthday","locale","gender","interests","education","fb_id","picture", 
      #{}"status", "request_org_id", "assignment", "organization_membership"],
      path = "/api/people/#{@user.person.id}"
      get path, {'access_token' => @access_token.code, 'fields' => "first_name,last_name,name,id,birthday,fb_id,picture,gender,education,interests,id,locale,location,assignment,request_org_id,organization_membership,status"}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json[0]['name'], "John Doe")
      assert_equal(@json[0]['picture'], "http://graph.facebook.com/690860831/picture")
      assert_equal(@json[0]['fb_id'], "690860831")
      assert_equal(@json[0]['first_name'], "John")
      assert_equal(@json[0]['last_name'], "Doe")
      assert_equal(@json[0]['locale'], "")
      assert_equal(@json[0]['birthday'], "1989-12-18")
      assert_equal(@json[0]['education'][0]['school']['name'], "Test High School")
      assert_equal(@json[0]['education'][1]['school']['name'], "Test University")
      assert_equal(@json[0]['education'][2]['school']['name'], "Test University 2")
      assert_equal(@json[0]['interests'][1]['name'], "Test Interest 2")
      assert_equal(@json[0]['gender'], "male")
      assert_equal(@json[0]['id'], @user.person.id)
      assert_equal(@json[0]['status'], "attempted_contact")
      assert_equal(@json[0]['assignment']['assigned_to_person'][0]['id'], @user.person.id)
      assert_equal(@json[0]['assignment']['person_assigned_to'][0]['id'], @user2.person.id)
      assert_equal(@json[0]['request_org_id'], @user.person.primary_organization.id)
      assert_equal(@json[0]['organization_membership'][0]['org_id'], @user.person.primary_organization.id)
      assert_equal(@json[0]['organization_membership'][0]['role'], @user.person.organization_memberships.first.role)
      assert_equal(@json[0]['organization_membership'][0]['primary'].downcase, 'true')
    end
    
    should "be able to get user friends" do
      path = "/api/friends/#{@user.person.id}"
      get path, {'access_token' => @access_token.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json[0]['person']['name'], @user.person.to_s)
      assert_equal(@json[0]['person']['id'], @user.person.id)
      assert_equal(@json[0]['friends'].length, 3)
      assert_equal(@json[0]['friends'][0]['name'],"Test Friend")
      assert_equal(@json[0]['friends'][0]['uid'], "1234567890")
      assert_equal(@json[0]['friends'][0]['provider'], "facebook")
    end
    
    context "with version 1 specified" do
      should "be able to request user information" do
        path = "/api/v1/people/#{@user.person.id}"
        get path, {'access_token' => @access_token.code}
        assert_response :success, @response.body
        @json = ActiveSupport::JSON.decode(@response.body)
        assert_equal(@json[0]['name'], "John Doe")
        assert_equal(@json[0]['picture'], "http://graph.facebook.com/690860831/picture")
        assert_equal(@json[0]['fb_id'], "690860831")
        assert_equal(@json[0]['first_name'], "John")
        assert_equal(@json[0]['last_name'], "Doe")
        assert_equal(@json[0]['locale'], "")
        assert_equal(@json[0]['birthday'], "1989-12-18")
        assert_equal(@json[0]['education'][0]['school']['name'], "Test High School")
        assert_equal(@json[0]['education'][1]['school']['name'], "Test University")
        assert_equal(@json[0]['education'][2]['school']['name'], "Test University 2")
        assert_equal(@json[0]['interests'][1]['name'], "Test Interest 2")
        assert_equal(@json[0]['gender'], "male")
        assert_equal(@json[0]['id'], @user.person.id)
        assert_equal(@json[0]['status'], "attempted_contact")
        assert_equal(@json[0]['assignment']['assigned_to_person'][0]['id'], @user.person.id)
        assert_equal(@json[0]['assignment']['person_assigned_to'][0]['id'], @user2.person.id)
        assert_equal(@json[0]['request_org_id'], @user.person.primary_organization.id)
        assert_equal(@json[0]['organization_membership'][0]['org_id'], @user.person.primary_organization.id)
        assert_equal(@json[0]['organization_membership'][0]['role'], @user.person.organization_memberships.first.role)
        assert_equal(@json[0]['organization_membership'][0]['primary'].downcase, 'true')
      end
    
      should "be able to request user information with fields" do
        path = "/api/v1/people/#{@user.person.id}"
        get path, {'access_token' => @access_token.code, 'fields' => "first_name,last_name,name,id,birthday,fb_id,picture,gender,education,interests,id,locale,location,assignment,request_org_id,organization_membership,status"}
         assert_response :success, @response.body
         @json = ActiveSupport::JSON.decode(@response.body)
         assert_equal(@json[0]['name'], "John Doe")
         assert_equal(@json[0]['picture'], "http://graph.facebook.com/690860831/picture")
         assert_equal(@json[0]['fb_id'], "690860831")
         assert_equal(@json[0]['first_name'], "John")
         assert_equal(@json[0]['last_name'], "Doe")
         assert_equal(@json[0]['locale'], "")
         assert_equal(@json[0]['birthday'], "1989-12-18")
         assert_equal(@json[0]['education'][0]['school']['name'], "Test High School")
         assert_equal(@json[0]['education'][1]['school']['name'], "Test University")
         assert_equal(@json[0]['education'][2]['school']['name'], "Test University 2")
         assert_equal(@json[0]['interests'][1]['name'], "Test Interest 2")
         assert_equal(@json[0]['gender'], "male")
         assert_equal(@json[0]['id'], @user.person.id)
         assert_equal(@json[0]['status'], "attempted_contact")
         assert_equal(@json[0]['assignment']['assigned_to_person'][0]['id'], @user.person.id)
         assert_equal(@json[0]['assignment']['person_assigned_to'][0]['id'], @user2.person.id)
         assert_equal(@json[0]['request_org_id'], @user.person.primary_organization.id)
         assert_equal(@json[0]['organization_membership'][0]['org_id'], @user.person.primary_organization.id)
         assert_equal(@json[0]['organization_membership'][0]['role'], @user.person.organization_memberships.first.role)
         assert_equal(@json[0]['organization_membership'][0]['primary'].downcase, 'true')
      end
    
      should "be able to get user friends" do
        path = "/api/v1/friends/#{@user.person.id}"
        get path, {'access_token' => @access_token.code}
        assert_response :success, @response.body
        @json = ActiveSupport::JSON.decode(@response.body)
        assert_equal(@json[0]['person']['name'], @user.person.to_s)
        assert_equal(@json[0]['person']['id'], @user.person.id)
        assert_equal(@json[0]['friends'].length, 3)
        assert_equal(@json[0]['friends'][0]['name'],"Test Friend")
        assert_equal(@json[0]['friends'][0]['uid'], "1234567890")
        assert_equal(@json[0]['friends'][0]['provider'], "facebook")
      end
    end
  end
end
