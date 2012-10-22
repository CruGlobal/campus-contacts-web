require 'test_helper'

class FriendTest < ActiveSupport::TestCase
  should belong_to(:person)
  should validate_presence_of(:name)
  should validate_presence_of(:provider)
  should validate_presence_of(:uid)
  should validate_presence_of(:person_id)
  
  context "a friend" do
    setup do
      @person = Factory(:person)
    end

    should "be able to add a friend" do
      friend1 = @person.friends.create(provider: "facebook", name: "Books", person_id: @person.id.to_i, uid: "1")
      assert friend1.valid?
    end

    should "be able to insert friendship to redis" do
      friend1 = @person.friends.create(provider: "facebook", name: "Books", person_id: @person.id.to_i, uid: "1")
      friend1.follow!(@person)
      assert_equal(Friend.followers(@person).length, 1)
      assert_equal(friend1.following?(@person), true)
    end
  end
end
