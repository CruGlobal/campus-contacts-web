require 'test_helper'

class Ccc::InfobaseUserTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  context "when merging" do
    setup do
      @user1 = Factory(:infobase_user, type: 'InfobaseUser')
      @user2 = Factory(:infobase_user, type: 'InfobaseHrUser')
      @user3 = Factory(:infobase_user, type: 'InfobaseAdminUser')
    end
    should "destroy user1 when merging with user2" do
      winner = @user1.merge(@user2)
      assert(@user1.frozen?)
      assert_equal(winner, @user2)
    end
    should "destroy user2 when merging with user3" do
      winner = @user3.merge(@user2)
      assert_equal(winner, @user3)
      assert(@user2.frozen?) 
    end
  end
end
