require 'test_helper'

class GroupLabelsControllerTest < ActionController::TestCase
  setup do
    @user, @org = admin_user_login_with_org
    @group = Factory(:group, organization: @org)
  end

  context "create" do
    should "create" do
      assert_difference "GroupLabel.count", 1 do
        xhr :post, :create, :group_label => {:name => "Groupie"}
      end
    end
  end
  
  context "destroy" do
    setup do
      @label = Factory(:group_label, organization: @org)
    end
  
    should "destroy" do
      assert_difference "GroupLabel.count", -1 do
        xhr :post, :destroy, {:id => @label.id}
      end
    end
  end
end
