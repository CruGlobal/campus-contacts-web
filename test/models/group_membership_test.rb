require 'test_helper'

class GroupMembershipTest < ActiveSupport::TestCase
  should belong_to(:group)
  should belong_to(:person)
  should belong_to(:leader)
  should belong_to(:member)
  should belong_to(:involved)
end
