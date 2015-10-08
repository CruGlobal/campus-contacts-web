require 'test_helper'

class GroupLabelingsControllerTest < ActionController::TestCase
  setup do
    @user, @org = admin_user_login_with_org
    @group = FactoryGirl.create(:group, organization: @org)
    @label = FactoryGirl.create(:group_label, organization: @org)
  end

  context 'create' do
    should 'create' do
      assert_difference 'GroupLabeling.count', 1 do
        xhr :post, :create, { group_label_id: @label.id, group_id: @group.id }
      end
    end
  end

  context 'destroy' do
    setup do
      FactoryGirl.create(:group_labeling, group: @group, group_label: @label)
    end

    should 'destroy' do
      assert_difference 'GroupLabeling.count', -1 do
        xhr :post, :destroy, id: @label.id, group_id: @group.id
      end
    end
  end
end
