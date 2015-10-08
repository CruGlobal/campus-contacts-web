require 'test_helper'

class SmsMailerTest < ActionMailer::TestCase
  test 'text WITHOUT reply_to' do
    mail = SmsMailer.text('to@example.com', 'from@example.com', 'Hi')
    assert_equal nil, mail.subject
    assert_equal ['to@example.com'], mail.to
    assert_equal ['from@example.com'], mail.from
    assert_match 'Hi', mail.body.encoded
  end

  test 'text WITH reply_to' do
    mail = SmsMailer.text('to@example.com', 'from@example.com', 'Hi', 'reply@example.com')
    assert_equal nil, mail.subject
    assert_equal ['to@example.com'], mail.to
    assert_equal ['from@example.com'], mail.from
    assert_equal ['reply@example.com'], mail.reply_to
    assert_match 'Hi', mail.body.encoded
  end
end
