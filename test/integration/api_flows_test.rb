require 'test_helper'

class ApiFlowsTest < ActionDispatch::IntegrationTest
#  fixtures :all

  context "a user action" do
    setup do
      @user = Factory.create(:user_with_auxs)
      @access_token = Factory.create(:access_token)
      @access_token.identity = @user.userID
      @access_token.client_id = 1
      #sign_in @user
      #@person = Factory(:person)
      #@person.fk_ssmUserId = @user.userID
    end
    
    should "request user information" do
      path = "/api/user/#{@user.userID}"
      get path, {'access_token' => @access_token.code}#, 'fields' => "first_name"}
      @json = Hashie::Mash.new(ActiveSupport::JSON.decode(@response.body))
      assert_equal(@json['name'], "John Doe")
      assert_equal(@json['picture'], "http://graph.facebook.com/690860831/picture")
      assert_equal(@json['fb_id'], "690860831")
      assert_equal(@json['first_name'], "John")
      assert_equal(@json['last_name'], "Doe")
      assert_equal(@json['locale'], "")
      assert_equal(@json['birthday'], "1989-12-18")
      assert_equal(@json['friends'], "")
      assert_equal(@json['gender'], "male")
      assert(@json.has_key?("id"))
      assert_equal(@json.interests, "")
    end
    
    should "request user information with fields" do
      path = "/api/user/#{@user.userID}"
      get path, {'access_token' => @access_token.code, 'fields' => "first_name,last_name,name,id,birthday,fb_id,picture,gender,friends,interests,id,locale,location"}
      @json = Hashie::Mash.new(ActiveSupport::JSON.decode(@response.body))
      assert_equal(@json['name'], "John Doe")
      assert_equal(@json['picture'], "http://graph.facebook.com/690860831/picture")
      assert_equal(@json['fb_id'], "690860831")
      assert_equal(@json['first_name'], "John")
      assert_equal(@json['last_name'], "Doe")
      assert_equal(@json['locale'], "")
      assert_equal(@json['birthday'], "1989-12-18")
      assert_equal(@json['friends'], "")
      assert_equal(@json['gender'], "male")
      assert(@json.has_key?("id"))
      assert_equal(@json.interests, "")
    end
    
    should "get user friends" do
      path = "/api/user/#{@user.userID}/friends"
      get path, {'access_token' => @access_token.code}
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json.length, 3)
      assert_equal(@json[0]['name'],"Test Friend")
      assert_equal(@json[0]['uid'], "1234567890")
      assert_equal(@json[0]['provider'], "facebook")
    end
    
    should "request user information with defined version" do
      path = "/api/v1/user/#{@user.userID}"
      get path, {'access_token' => @access_token.code}#, 'fields' => "first_name"}
      @json = Hashie::Mash.new(ActiveSupport::JSON.decode(@response.body))
      assert_equal(@json['name'], "John Doe")
      assert_equal(@json['picture'], "http://graph.facebook.com/690860831/picture")
      assert_equal(@json['fb_id'], "690860831")
      assert_equal(@json['first_name'], "John")
      assert_equal(@json['last_name'], "Doe")
      assert_equal(@json['locale'], "")
      assert_equal(@json['birthday'], "1989-12-18")
      assert_equal(@json['friends'], "")
      assert_equal(@json['gender'], "male")
      assert(@json.has_key?("id"))
      assert_equal(@json.interests, "")
    end
    
    should "request user information with fields with defined version" do
      path = "/api/v1/user/#{@user.userID}"
      get path, {'access_token' => @access_token.code, 'fields' => "first_name,last_name,name,id,birthday,fb_id,picture,gender,friends,interests,id,locale,location"}
      @json = Hashie::Mash.new(ActiveSupport::JSON.decode(@response.body))
      assert_equal(@json['name'], "John Doe")
      assert_equal(@json['picture'], "http://graph.facebook.com/690860831/picture")
      assert_equal(@json['fb_id'], "690860831")
      assert_equal(@json['first_name'], "John")
      assert_equal(@json['last_name'], "Doe")
      assert_equal(@json['locale'], "")
      assert_equal(@json['birthday'], "1989-12-18")
      assert_equal(@json['friends'], "")
      assert_equal(@json['gender'], "male")
      assert(@json.has_key?("id"))
      assert_equal(@json.interests, "")
    end
    
    should "get user friends with defined version" do
      path = "/api/v1/user/#{@user.userID}/friends"
      get path, {'access_token' => @access_token.code}
      @json = ActiveSupport::JSON.decode(@response.body)
      assert_equal(@json.length, 3)
      assert_equal(@json[0]['name'],"Test Friend")
      assert_equal(@json[0]['uid'], "1234567890")
      assert_equal(@json[0]['provider'], "facebook")
    end
  end
end
