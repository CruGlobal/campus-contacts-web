require 'test_helper'

class FriendTest < ActiveSupport::TestCase

  context "a friend" do
    setup do
      @person = Factory(:person)
    end


    should "be able to insert friendship to redis" do
      friend1 = Friend.new('1', 'Books', @person)
      assert_equal(Friend.followers(@person).length, 1)
    end
  end
end
