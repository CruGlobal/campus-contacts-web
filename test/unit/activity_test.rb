require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  should belong_to(:target_area)
  should belong_to(:organization)
  
  should "set start date" do
    activity = Activity.new(:status => "test")
    assert activity.save
    
    assert_equal Date.today, Activity.last.start_date
  end
end
