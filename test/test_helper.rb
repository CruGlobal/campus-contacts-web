ENV["RAILS_ENV"] = "test"
require 'simplecov'
# SimpleCov.start 'rails' do
#   add_filter "/vendor/"
# end
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'ephemeral_response'
require 'factory_girl'
require File.dirname(__FILE__) + "/factories"

EphemeralResponse.activate

EphemeralResponse.configure do |config|
  config.fixture_directory = "test/fixtures/ephemeral_response"
  config.white_list = 'localhost'
end

Devise::OmniAuth.test_mode!

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