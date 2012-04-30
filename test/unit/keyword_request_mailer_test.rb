require 'test_helper'

class KeywordRequestMailerTest < ActiveSupport::TestCase
  setup do
    user = Factory(:user_with_auxs)
    @keyword = Factory(:sms_keyword, user: user, organization: user.person.organizations.first, keyword: "Wat")
  end
  
  test "new keyword request" do
    KeywordRequestMailer.new_keyword_request(@keyword.id).deliver
    content = ActionMailer::Base.deliveries.last
    assert_match /New sms keyword request/, content.subject.to_s
  end
  
  test "notify user" do
    KeywordRequestMailer.notify_user(@keyword).deliver
    content = ActionMailer::Base.deliveries.last
    assert_match /Keyword 'Wat' was approved/, content.subject.to_s
  end
  
  test "notify user of denial" do
    KeywordRequestMailer.notify_user_of_denial(@keyword).deliver
    content = ActionMailer::Base.deliveries.last
    assert_match /Keyword 'Wat' was rejected/, content.subject.to_s
  end
end
