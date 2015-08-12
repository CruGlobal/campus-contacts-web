ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"
require "minitest/rails"
require 'mocha/mini_test'
require 'webmock/minitest'
require 'rack/oauth2/server'
require 'shoulda'
require 'api_test_helper'
require 'sidekiq/testing'
require "strip_attributes/matchers"

class MiniTest::Spec
  include StripAttributes::Matchers
end

#Sidekiq::Testing.inline!
# EphemeralResponse.activate
#
# EphemeralResponse.configure do |config|
#   config.fixture_directory = "test/fixtures/ephemeral_response"
#   config.white_list = 'localhost'
# end


# To add Capybara feature tests add `gem "minitest-rails-capybara"`
# to the test group in the Gemfile and uncomment the following:
# require "minitest/rails/capybara"

# Uncomment for awesome colorful output
require "minitest/pride"

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
  Permission.admin
  Permission.user
  Permission.no_permissions
  Label.involved
  Label.engaged_disciple
  Label.leader
  Label.seeker
end

class ActionController::TestCase
  include Devise::TestHelpers
end

#Devise::OmniAuth.test_mode!
OmniAuth.config.test_mode = true
OmniAuth.config.add_mock(:facebook, {"provider"=>"facebook", "uid"=>"690860831", "credentials"=>{"token"=>"164949660195249|bd3f24d52b4baf9412141538.1-690860831|w79R36CalrEAY-9e9kp8fDWJ69A"}, "user_info"=>{"nickname"=>"mattrw89", "email"=>"mattrw89@gmail.com", "first_name"=>"Matt", "last_name"=>"Webb", "name"=>"Matt Webb", "image"=>"http://graph.facebook.com/v2.2/690860831/picture?type=square", "urls"=>{"Facebook"=>"http://www.facebook.com/mattrw89", "Website"=>nil}}, "extra"=>{"user_hash"=>{"id"=>"690860831", "name"=>"Matt Webb", "first_name"=>"Matt", "last_name"=>"Webb", "link"=>"http://www.facebook.com/mattrw89", "username"=>"mattrw89", "birthday"=>"12/18/1989", "location"=>{"id"=>"108288992526695", "name"=>"Orlando, Florida"}, "education"=>[{"school"=>{"id"=>"115045251844283", "name"=>"Niceville Senior High"}, "year"=>{"id"=>"141778012509913", "name"=>"2008"}, "type"=>"High School"}, {"school"=>{"id"=>"35078114590", "name"=>"University of Central Florida"}, "year"=>{"id"=>"118118634930920", "name"=>"2012"}, "concentration"=>[{"id"=>"124764794262413", "name"=>"Electrical Engineering"}], "type"=>"College"}], "gender"=>"male", "email"=>"mattrw89@gmail.com", "timezone"=>-4, "locale"=>"en_US", "languages"=>[{"id"=>"137946929599946", "name"=>"FORTRAN 66,77"}, {"id"=>"133255596736945", "name"=>"ruby"}, {"id"=>"189887071024044", "name"=>"Objective C"}], "verified"=>true, "updated_time"=>"2011-05-23T12:07:56+0000"}}})

# class Test::Unit::TestCase
#   extend StripAttributes::Matchers
# end

# unless defined?(Test::Unit::AssertionFailedError)
#   class Test::Unit::AssertionFailedError < ActiveSupport::TestCase::Assertion
#   end
# end

class TestFBResponses
  FULL = Hashie::Mash.new(ActiveSupport::JSON.decode('{"raw_attributes":{"id":"690860831","name":"Matt Webb","first_name":"Matt","last_name":"Webb","link":"http:\/\/www.facebook.com\/mattrw89","username":"mattrw89","birthday":"12\/18\/1989","gender":"male","email":"mattrw89\u0040gmail.com","timezone":-4,"locale":"en_US","verified":true,"updated_time":"2011-05-23T12:07:56+0000"},"location":{"raw_attributes":{"id":"108288992526695","name":"Orlando, Florida"}},"education":[{"school":{"raw_attributes":{"id":"1150452518442831","name":"Niceville Senior High"}},"year":{"raw_attributes":{"id":"141778012509913","name":"2008"}},"type":"High School"},{"school":{"raw_attributes":{"id":"350781145901","name":"University of Central Florida"}},"year":{"raw_attributes":{"id":"118118634930920","name":"2012"}},"degree":{"raw_attributes":{"id":"12312","name":"Masters"}},"concentration":[{"raw_attributes":{"id":"124764794262413","name":"Electrical Engineering"}},{"raw_attributes":{"id":"123124124","name":"Underwater Basket Weaving"}},{"raw_attributes":{"id":"131212512","name":"Chick Fil A Consumption"}}],"type":"College"}],"languages":[{"raw_attributes":{"id":"137946929599946","name":"FORTRAN 66,77"}},{"raw_attributes":{"id":"133255596736945","name":"ruby"}},{"raw_attributes":{"id":"189887071024044","name":"Objective C"}}],"interests":[{"raw_attributes":{"name":"Music","category":"Field of study","id":"112936425387489","created_time":"2010-04-23T17:34:48+0000"}},{"raw_attributes":{"name":"Jesus","category":"Public figure","id":"104332632936376","created_time":"2010-04-23T17:34:48+0000"}}]}'))

  NO_CONCENTRATION = Hashie::Mash.new(ActiveSupport::JSON.decode('{"raw_attributes":{"id":"690860831","name":"Matt Webb","first_name":"Matt","last_name":"Webb","link":"http:\/\/www.facebook.com\/mattrw89","username":"mattrw89","birthday":"12\/18\/1989","gender":"male","email":"mattrw89\u0040gmail.com","timezone":-4,"locale":"en_US","verified":true,"updated_time":"2011-05-23T12:07:56+0000"},"location":{"raw_attributes":{"id":"108288992526695","name":"Orlando, Florida"}},"education":[{"school":{"raw_attributes":{"id":"1150452518442831","name":"Niceville Senior High"}},"year":{"raw_attributes":{"id":"141778012509913","name":"2008"}},"type":"High School"},{"school":{"raw_attributes":{"id":"350781145901","name":"University of Central Florida"}},"year":{"raw_attributes":{"id":"118118634930920","name":"2012"}},"degree":{"raw_attributes":{"id":"12312","name":"Masters"}},"type":"College"}],"languages":[{"raw_attributes":{"id":"137946929599946","name":"FORTRAN 66,77"}},{"raw_attributes":{"id":"133255596736945","name":"ruby"}},{"raw_attributes":{"id":"189887071024044","name":"Objective C"}}],"interests":[{"raw_attributes":{"name":"Music","category":"Field of study","id":"112936425387489","created_time":"2010-04-23T17:34:48+0000"}},{"raw_attributes":{"name":"Jesus","category":"Public figure","id":"104332632936376","created_time":"2010-04-23T17:34:48+0000"}}]}'))

  NO_YEAR = Hashie::Mash.new(ActiveSupport::JSON.decode('{"raw_attributes":{"id":"690860831","name":"Matt Webb","first_name":"Matt","last_name":"Webb","link":"http:\/\/www.facebook.com\/mattrw89","username":"mattrw89","birthday":"12\/18\/1989","gender":"male","email":"mattrw89\u0040gmail.com","timezone":-4,"locale":"en_US","verified":true,"updated_time":"2011-05-23T12:07:56+0000"},"location":{"raw_attributes":{"id":"108288992526695","name":"Orlando, Florida"}},"education":[{"school":{"raw_attributes":{"id":"1150452518442831","name":"Niceville Senior High"}},"type":"High School"},{"school":{"raw_attributes":{"id":"350781145901","name":"University of Central Florida"}},"year":{"raw_attributes":{"id":"118118634930920","name":"2012"}},"degree":{"raw_attributes":{"id":"12312","name":"Masters"}},"concentration":[{"raw_attributes":{"id":"124764794262413","name":"Electrical Engineering"}},{"raw_attributes":{"id":"123124124","name":"Underwater Basket Weaving"}},{"raw_attributes":{"id":"131212512","name":"Chick Fil A Consumption"}}],"type":"College"}],"languages":[{"raw_attributes":{"id":"137946929599946","name":"FORTRAN 66,77"}},{"raw_attributes":{"id":"133255596736945","name":"ruby"}},{"raw_attributes":{"id":"189887071024044","name":"Objective C"}}],"interests":[{"raw_attributes":{"name":"Music","category":"Field of study","id":"112936425387489","created_time":"2010-04-23T17:34:48+0000"}},{"raw_attributes":{"name":"Jesus","category":"Public figure","id":"104332632936376","created_time":"2010-04-23T17:34:48+0000"}}]}'))

  NO_DEGREE = Hashie::Mash.new(ActiveSupport::JSON.decode('{"raw_attributes":{"id":"690860831","name":"Matt Webb","first_name":"Matt","last_name":"Webb","link":"http:\/\/www.facebook.com\/mattrw89","username":"mattrw89","birthday":"12\/18\/1989","gender":"male","email":"mattrw89\u0040gmail.com","timezone":-4,"locale":"en_US","verified":true,"updated_time":"2011-05-23T12:07:56+0000"},"location":{"raw_attributes":{"id":"108288992526695","name":"Orlando, Florida"}},"education":[{"school":{"raw_attributes":{"id":"1150452518442831","name":"Niceville Senior High"}},"year":{"raw_attributes":{"id":"141778012509913","name":"2008"}},"type":"High School"},{"school":{"raw_attributes":{"id":"350781145901","name":"University of Central Florida"}},"year":{"raw_attributes":{"id":"118118634930920","name":"2012"}},"concentration":[{"raw_attributes":{"id":"124764794262413","name":"Electrical Engineering"}},{"raw_attributes":{"id":"123124124","name":"Underwater Basket Weaving"}},{"raw_attributes":{"id":"131212512","name":"Chick Fil A Consumption"}}],"type":"College"}],"languages":[{"raw_attributes":{"id":"137946929599946","name":"FORTRAN 66,77"}},{"raw_attributes":{"id":"133255596736945","name":"ruby"}},{"raw_attributes":{"id":"189887071024044","name":"Objective C"}}],"interests":[{"raw_attributes":{"name":"Music","category":"Field of study","id":"112936425387489","created_time":"2010-04-23T17:34:48+0000"}},{"raw_attributes":{"name":"Jesus","category":"Public figure","id":"104332632936376","created_time":"2010-04-23T17:34:48+0000"}}]}'))

  NO_EDUCATION = Hashie::Mash.new(ActiveSupport::JSON.decode('{"raw_attributes":{"id":"690860831","name":"Matt Webb","first_name":"Matt","last_name":"Webb","link":"http:\/\/www.facebook.com\/mattrw89","username":"mattrw89","birthday":"12\/18\/1989","gender":"male","email":"mattrw89\u0040gmail.com","timezone":-4,"locale":"en_US","verified":true,"updated_time":"2011-05-23T12:07:56+0000"},"location":{"raw_attributes":{"id":"108288992526695","name":"Orlando, Florida"}},"languages":[{"raw_attributes":{"id":"137946929599946","name":"FORTRAN 66,77"}},{"raw_attributes":{"id":"133255596736945","name":"ruby"}},{"raw_attributes":{"id":"189887071024044","name":"Objective C"}}],"interests":[{"raw_attributes":{"name":"Music","category":"Field of study","id":"112936425387489","created_time":"2010-04-23T17:34:48+0000"}},{"raw_attributes":{"name":"Jesus","category":"Public figure","id":"104332632936376","created_time":"2010-04-23T17:34:48+0000"}}]}'))


  FULL_WITH_FRIENDS = Hashie::Mash.new(ActiveSupport::JSON.decode('{"raw_attributes":{"id":"690860831","name":"Matt Webb","first_name":"Matt","last_name":"Webb","link":"http:\/\/www.facebook.com\/mattrw89","username":"mattrw89","birthday":"12\/18\/1989","gender":"male","email":"mattrw89\u0040gmail.com","timezone":-4,"locale":"en_US","verified":true,"updated_time":"2011-05-23T12:07:56+0000"},"location":{"raw_attributes":{"id":"108288992526695","name":"Orlando, Florida"}},"education":[{"school":{"raw_attributes":{"id":"1150452518442831","name":"Niceville Senior High"}},"year":{"raw_attributes":{"id":"141778012509913","name":"2008"}},"type":"High School"},{"school":{"raw_attributes":{"id":"350781145901","name":"University of Central Florida"}},"year":{"raw_attributes":{"id":"118118634930920","name":"2012"}},"degree":{"raw_attributes":{"id":"12312","name":"Masters"}},"concentration":[{"raw_attributes":{"id":"124764794262413","name":"Electrical Engineering"}},{"raw_attributes":{"id":"123124124","name":"Underwater Basket Weaving"}},{"raw_attributes":{"id":"131212512","name":"Chick Fil A Consumption"}}],"type":"College"}],"languages":[{"raw_attributes":{"id":"137946929599946","name":"FORTRAN 66,77"}},{"raw_attributes":{"id":"133255596736945","name":"ruby"}},{"raw_attributes":{"id":"189887071024044","name":"Objective C"}}],"interests":[{"raw_attributes":{"name":"Music","category":"Field of study","id":"112936425387489","created_time":"2010-04-23T17:34:48+0000"}},{"raw_attributes":{"name":"Jesus","category":"Public figure","id":"104332632936376","created_time":"2010-04-23T17:34:48+0000"}}],"friends":[{"raw_attributes":{"name":"Dan Wiley","id":"1307553"}},{"raw_attributes":{"name":"Kris Hodges","id":"2007376"}},{"raw_attributes":{"name":"Peter Thompson","id":"2008861"}},{"raw_attributes":{"name":"Jason Davis","id":"2044141"}},{"raw_attributes":{"name":"Chip Thorn","id":"2057110"}},{"raw_attributes":{"name":"Luke Russell","id":"2064076"}}]}'))
end


def admin_user_login_with_org
  @user = FactoryGirl.create(:user_with_auxs)
  @org = @user.person.organizations.first
  @request.session[:current_organization_id] = @org.id

  sign_in @user
  return @user, @org
end
