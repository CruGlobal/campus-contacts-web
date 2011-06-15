require 'test_helper'

class ApiFlowsTest < ActionDispatch::IntegrationTest

  context "a user action" do
    setup do
      @user = Factory.create(:user_with_auxs)
      @access_token = Factory.create(:access_token, :identity => @user.id)
    end
    
    should "request user information" do
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
    end
    
    should "request user information with fields" do
      path = "/api/people/#{@user.person.id}"
      get path, {'access_token' => @access_token.code, 'fields' => "first_name,last_name,name,id,birthday,fb_id,picture,gender,education,interests,id,locale,location"}
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
    end
    
    should "get user friends" do
      path = "/api/friends/#{@user.person.id}"
      get path, {'access_token' => @access_token.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json[0]['friends'].length, 3)
      assert_equal(@json[0]['friends'][0]['name'],"Test Friend")
      assert_equal(@json[0]['friends'][0]['uid'], "1234567890")
      assert_equal(@json[0]['friends'][0]['provider'], "facebook")
    end
    context "with version 1 specified" do
      should "request user information" do
        path = "/api/v1/people/#{@user.person.id}"
        get path, {'access_token' => @access_token.code}#, 'fields' => "first_name"}
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
      end
    
      should "request user information with fields" do
        path = "/api/v1/people/#{@user.person.id}"
        get path, {'access_token' => @access_token.code, 'fields' => "first_name,last_name,name,id,birthday,fb_id,picture,gender,education,interests,id,locale,location"}
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
      end
    
      should "get user friends" do
        path = "/api/v1/friends/#{@user.person.id}"
        get path, {'access_token' => @access_token.code}
        assert_response :success, @response.body
        @json = ActiveSupport::JSON.decode(@response.body)
        assert_equal(@json[0]['friends'].length, 3)
        assert_equal(@json[0]['friends'][0]['name'],"Test Friend")
        assert_equal(@json[0]['friends'][0]['uid'], "1234567890")
        assert_equal(@json[0]['friends'][0]['provider'], "facebook")
      end
    end
  end
end
