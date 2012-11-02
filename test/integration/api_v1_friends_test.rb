require 'test_helper'
include ApiTestHelper

class ApiV1FriendsTest < ActionDispatch::IntegrationTest
  context "the api" do
    setup do
      setup_api_env
      3.times { |i| Friend.new(i, 'Foo', @user.person) }
    end
    should "be able to get person friends" do
      path = "/api/friends/#{@user.person.id}"
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)

      person_mini_test(@json[0]['person'],@user)
      assert_equal(@json[0]['friends'].length, 3)
      friend_test(@json[0]['friends'][0], @user.person.friends.first)
    end
    
    should "be able to get person friends with v1 specified" do
      path = "/api/v1/friends/#{@user.person.id}"
      get path, {'access_token' => @access_token3.code}
      assert_response :success, @response.body
      @json = ActiveSupport::JSON.decode(@response.body)
      
      person_mini_test(@json[0]['person'],@user)
      assert_equal(@json[0]['friends'].length, 3)
      friend_test(@json[0]['friends'][0], @user.person.friends.first)
    end
  end
end
