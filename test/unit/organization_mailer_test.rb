require 'test_helper'

class OrganizationMailerTest < ActiveSupport::TestCase
  setup do
    @user = Factory(:user_with_auxs)
    @org = @user.person.organizations.first
  end
  
  test "notify admin of request" do
    OrganizationMailer.notify_admin_of_request(@org).deliver
    content = ActionMailer::Base.deliveries.last
    assert_match /New organization request/, content.subject.to_s
  end
  
  test "notify user" do
    OrganizationMailer.notify_user(@org).deliver
    content = ActionMailer::Base.deliveries.last
    assert_match /Organization '#{@org}' was approved!/, content.subject.to_s
  end
  
  test "notify user of denial" do
    OrganizationMailer.notify_user_of_denial(@org).deliver
    content = ActionMailer::Base.deliveries.last
    assert_match /Organization '#{@org}' was rejected./, content.subject.to_s
  end
end
