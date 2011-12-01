require 'test_helper'

class OrganizationMailerTest < ActionMailer::TestCase
  test "notify_admin_of_request" do
    mail = OrganizationMailer.notify_admin_of_request(Factory(:organization).id)
    assert_equal "New organization request", mail.subject
    assert_equal ["support@missionhub.com"], mail.to
    assert_equal ["support@missionhub.com"], mail.from
  end

end
