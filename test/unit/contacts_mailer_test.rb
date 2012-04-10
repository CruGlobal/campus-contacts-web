require 'test_helper'

class ContactsMailerTest < ActiveSupport::TestCase
  
  should "create correct reminder" do
    ContactsMailer.reminder("vincent.paca@gmail.com", "support@missionhub,com", "subject", "content").deliver
    content = ActionMailer::Base.deliveries.last
    
    assert_match /content/, content.body.to_s
  end
  
end
