require 'test_helper'

class SmsMailerTest < ActionMailer::TestCase
  test "text" do
    mail = SmsMailer.text('to@example.com', 'Hi', SmsKeyword.default)
    assert_equal "Text", mail.subject
    assert_equal ["to@example.com"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
