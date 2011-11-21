require 'test_helper'

class OrganizationMailerTest < ActionMailer::TestCase
  test "notify_admin_of_request" do
    mail = OrganizationMailer.notify_admin_of_request
    assert_equal "Notify admin of request", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
