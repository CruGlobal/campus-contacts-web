require 'test_helper'

class Users::OmniauthCallbacksControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  context "Logging into facbook from mhub" do
    setup do
      request.env["devise.mapping"] = Devise.mappings[:user]
    end
    should "redirect back to root" do
      # request.env["omniauth.auth"] = {"provider"=>"facebook_mhub", "uid"=>"1501344135", "credentials"=>{"token"=>"169839456413947|92aab8da75bec2168e864c84.1-1501344135|W1ADmO83M8DGipdXGccY8kP1AZU"}, "user_info"=>{"nickname"=>"montalvo2011", "email"=>"montalvo7211@gmail.com", "first_name"=>"Tiffany", "last_name"=>"Montalvo", "name"=>"Tiffany Montalvo", "image"=>"http://graph.facebook.com/1501344135/picture?type=square", "urls"=>{"Facebook"=>"http://www.facebook.com/montalvo2011", "key"=>"Website"}}, "extra"=>{"user_hash"=>{"id"=>"1501344135", "name"=>"Tiffany Nicole Montalvo", "first_name"=>"Tiffany", "middle_name"=>"Nicole", "last_name"=>"Montalvo", "link"=>"http://www.facebook.com/montalvo2011", "username"=>"montalvo2011", "birthday"=>"05/14/1993", "location"=>{"id"=>"106021666096708", "name"=>"Toledo, Ohio"}, "education"=>"[{\"school\"=>{\"id\"=>\"105644972801622\", \"name\"=>\"Dickinson High School\"}, \"year\"=>{\"id\"=>\"144044875610606\", \"name\"=>\"2011\"}, \"type\"=>\"High School\"}, {\"school\"=>{\"id\"=>\"109499409076376\", \"name\"=>\"University of Toledo\"}, \"year\"=>{\"id\"=>\"105576766163075\", \"name\"=>\"2015\"}, \"concentration\"=>[{\"id\"=>\"135941049807020\", \"name\"=>\"Pharmaceutical Sciences\"}], \"type\"=>\"College\"}]", "gender"=>"female", "email"=>"montalvo7211@gmail.com", "timezone"=>"-4", "locale"=>"en_US", "verified"=>"true", "updated_time"=>"2011-08-17T00:52:25+0000"}}}
      @controller.stubs(:env).returns("omniauth.auth" => {"provider"=>"facebook_mhub", "uid"=>"1501344135", "credentials"=>{"token"=>"169839456413947|92aab8da75bec2168e864c84.1-1501344135|W1ADmO83M8DGipdXGccY8kP1AZU"}, "user_info"=>{"nickname"=>"montalvo2011", "email"=>"montalvo7211@gmail.com", "first_name"=>"Tiffany", "last_name"=>"Montalvo", "name"=>"Tiffany Montalvo", "image"=>"http://graph.facebook.com/1501344135/picture?type=square", "urls"=>{"Facebook"=>"http://www.facebook.com/montalvo2011", "key"=>"Website"}}, "extra"=>{"user_hash"=>{"id"=>"1501344135", "name"=>"Tiffany Nicole Montalvo", "first_name"=>"Tiffany", "middle_name"=>"Nicole", "last_name"=>"Montalvo", "link"=>"http://www.facebook.com/montalvo2011", "username"=>"montalvo2011", "birthday"=>"05/14/1993", "location"=>{"id"=>"106021666096708", "name"=>"Toledo, Ohio"}, "education"=>"[{\"school\"=>{\"id\"=>\"105644972801622\", \"name\"=>\"Dickinson High School\"}, \"year\"=>{\"id\"=>\"144044875610606\", \"name\"=>\"2011\"}, \"type\"=>\"High School\"}, {\"school\"=>{\"id\"=>\"109499409076376\", \"name\"=>\"University of Toledo\"}, \"year\"=>{\"id\"=>\"105576766163075\", \"name\"=>\"2015\"}, \"concentration\"=>[{\"id\"=>\"135941049807020\", \"name\"=>\"Pharmaceutical Sciences\"}], \"type\"=>\"College\"}]", "gender"=>"female", "email"=>"montalvo7211@gmail.com", "timezone"=>"-4", "locale"=>"en_US", "verified"=>"true", "updated_time"=>"2011-08-17T00:52:25+0000"}}})
      assert_difference("User.count") do
        get :facebook_mhub
      end
      user = assigns(:user)
      assert(user, 'No user assigned')
      assert_equal('montalvo7211@gmail.com', user.username)
      assert_redirected_to '/'
    end
  end
end
