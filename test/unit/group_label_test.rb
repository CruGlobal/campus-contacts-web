require 'test_helper'

class GroupLabelTest < ActiveSupport::TestCase
  should "return the group label name" do
    org = Factory(:organization)
    label = GroupLabel.new(:name => "Wat", :organization_id => org.id)
    
    assert label.save
    assert_equal "Wat", GroupLabel.last.to_s
  end
end
