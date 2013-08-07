require 'test_helper'

class Users::OmniauthCallbacksControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  context "Logging into facbook from mhub" do
    setup do
      stub_request(:get, "https://graph.facebook.com/5?access_token=a").to_return(:status => 200, :body => "{}", :headers => {})
      request.env["devise.mapping"] = Devise.mappings[:user]
      @controller.stubs(:env).returns("omniauth.auth" => Hashie::Mash.new(uid: '5', credentials: {token: 'a', expires_at: 5}, extra: {raw_info: {first_name: 'John', last_name: 'Doe', email: 'test@example.com'}}))
    end

    should "create a user" do
      assert_difference("User.count") do
        get :facebook_mhub
      end
      user = assigns(:user)
      assert(user, 'No user assigned')
      assert_equal('test@example.com', user.username)
    end

    should "not puke if facebook email is already assigned to another person" do
      user2 = Factory(:user_with_auxs)
      user2.person.update_attribute(:email, 'test@example.com')

      assert_no_difference("User.count") do
        get :facebook_mhub
      end
      user = assigns(:user)
      assert(user, 'No user assigned')
      assert_equal(user.id, user2.id)
    end
  end

  context "Logging into facbook from normal MissionHub" do
    setup do
      stub_request(:get, "https://graph.facebook.com/5?access_token=a").to_return(:status => 200, :body => "{}", :headers => {})
      request.env["devise.mapping"] = Devise.mappings[:user]
      @controller.stubs(:env).returns("omniauth.auth" => Hashie::Mash.new(uid: '5', credentials: {token: 'a', expires_at: 5}, extra: {raw_info: {first_name: 'Fred', last_name: 'Doe', email: 'test@example.com'}}))
    end

    should "create a user" do
      assert_difference("User.count") do
        get :facebook
      end
      user = assigns(:user)
      assert(user, 'No user assigned')
      assert_equal('test@example.com', user.username)
    end

    # Start, codes changed: August 06, 2013
    # Purpose: to consider the possibility that the existing users will change their names from Facebook and tries to login to missionhub.
    # Model: user.rb line 55
    #should "redirect to duplicate message if email is assigned to a person with a different name" do
    #  user2 = Factory(:user_with_auxs)
    #  user2.person.update_attribute(:email, 'test@example.com')

    #  assert_no_difference("User.count") do
    #    get :facebook
    #  end

    #  assert_redirected_to '/welcome/duplicate'
    #end
    # End, codes changed: August 06, 2013

    should "merge gracefully if email is assigned to a person with the same name" do
      user2 = Factory(:user_with_auxs)
      user2.person.update_attributes(email: 'test@example.com', first_name: 'Fred')

      assert_no_difference("User.count") do
        get :facebook
      end

      assert_redirected_to 'http://test.host/dashboard'
    end

  end

end
