require 'test_helper'

class VcardMailerTest < ActiveSupport::TestCase
  test "vcard" do
    user = Factory(:user_with_auxs)
    
    VcardMailer.vcard("vincent.paca@gmail.com", user.person.id).deliver
    content = ActionMailer::Base.deliveries.last
    
    assert_match /Contact information#{user.person.name}/, content.subject.to_s
    assert_equal 1, content.attachments.count
  end
  
  test "bulk vcard" do
    user1 = Factory(:user_with_auxs)
    user2 = Factory(:user_with_auxs)  
    ids = []
    ids << user1.person.id
    ids << user2.person.id
    
    VcardMailer.bulk_vcard("vincent.paca@gmail.com", ids).deliver
    content = ActionMailer::Base.deliveries.last
    
    assert_match /Your request for contact information/, content.subject.to_s
    assert_equal 1, content.attachments.count
  end
end

