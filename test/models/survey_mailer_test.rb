require 'test_helper'

class SurveyMailerTest < ActiveSupport::TestCase
  test 'bulk message' do
    SurveyMailer.notify('vincent.paca@gmail.com', 'Hey').deliver_now
    content = ActionMailer::Base.deliveries.last

    assert_match /Hey/, content.body.to_s
  end
end
