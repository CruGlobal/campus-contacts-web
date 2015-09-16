require 'test_helper'

class FriendTest < ActiveSupport::TestCase

  context "a friend" do
    setup do
      @person = FactoryGirl.create(:person)
    end


    should "be able to insert friendship to redis" do
      Friend.unfollow(@person, '1')
      assert_difference("Friend.followers(@person).length") do
        friend1 = Friend.new('1', 'Books', @person)
      end
    end
  end
end
