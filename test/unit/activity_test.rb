require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  should belong_to(:target_area)
  should belong_to(:organization)

end
