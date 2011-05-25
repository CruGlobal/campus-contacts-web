ENV["RAILS_ENV"] = "test"
require 'simplecov'
# SimpleCov.start 'rails' do
#   add_filter "vendor"
# end
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'shoulda/rails'
require 'ephemeral_response'
require 'factory_girl'
require File.dirname(__FILE__) + "/factories"

EphemeralResponse.activate

EphemeralResponse.configure do |config|
  config.fixture_directory = "test/fixtures/ephemeral_response"
  config.white_list = 'localhost'
end

#Devise::OmniAuth.test_mode!
OmniAuth.config.test_mode = true
OmniAuth.config.add_mock(:facebook, {"provider"=>"facebook", "uid"=>"690860831", "credentials"=>{"token"=>"164949660195249|bd3f24d52b4baf9412141538.1-690860831|w79R36CalrEAY-9e9kp8fDWJ69A"}, "user_info"=>{"nickname"=>"mattrw89", "email"=>"mattrw89@gmail.com", "first_name"=>"Matt", "last_name"=>"Webb", "name"=>"Matt Webb", "image"=>"http://graph.facebook.com/690860831/picture?type=square", "urls"=>{"Facebook"=>"http://www.facebook.com/mattrw89", "Website"=>nil}}, "extra"=>{"user_hash"=>{"id"=>"690860831", "name"=>"Matt Webb", "first_name"=>"Matt", "last_name"=>"Webb", "link"=>"http://www.facebook.com/mattrw89", "username"=>"mattrw89", "birthday"=>"12/18/1989", "location"=>{"id"=>"108288992526695", "name"=>"Orlando, Florida"}, "education"=>[{"school"=>{"id"=>"115045251844283", "name"=>"Niceville Senior High"}, "year"=>{"id"=>"141778012509913", "name"=>"2008"}, "type"=>"High School"}, {"school"=>{"id"=>"35078114590", "name"=>"University of Central Florida"}, "year"=>{"id"=>"118118634930920", "name"=>"2012"}, "concentration"=>[{"id"=>"124764794262413", "name"=>"Electrical Engineering"}], "type"=>"College"}], "gender"=>"male", "email"=>"mattrw89@gmail.com", "timezone"=>-4, "locale"=>"en_US", "languages"=>[{"id"=>"137946929599946", "name"=>"FORTRAN 66,77"}, {"id"=>"133255596736945", "name"=>"ruby"}, {"id"=>"189887071024044", "name"=>"Objective C"}], "verified"=>true, "updated_time"=>"2011-05-23T12:07:56+0000"}}})
class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  # fixtures :all

  # Add more helper methods to be used by all tests here...
end

class ActionController::TestCase
  include Devise::TestHelpers
end

unless defined?(Test::Unit::AssertionFailedError)
  class Test::Unit::AssertionFailedError < ActiveSupport::TestCase::Assertion
  end
end