require 'test_helper'

class VcardMailerTest < ActiveSupport::TestCase
  test "bulk message" do
    PeopleMailer.bulk_message("vincent.paca@gmail.com", "support@missionhub,com", "subject", "content").deliver
    content = ActionMailer::Base.deliveries.last
    
    assert_match /content/, content.body.to_s
  end
end

