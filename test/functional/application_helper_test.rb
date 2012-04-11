require 'test_helper'
require 'application_helper'

class ApplicationHelperTest < Test::Unit::TestCase
  include ApplicationHelper
  
  test "uri" do
    assert uri?("http://google.com")
    assert uri?("https://facebook.com")
    assert !uri?("hahahahah")
  end
end
