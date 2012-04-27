require 'test_helper'

class SmsKeywordTest < ActiveSupport::TestCase
  should belong_to(:user)
  should belong_to(:survey)
  should belong_to(:event)
  should belong_to(:organization)
  
  should have_many(:questions)
  should have_many(:archived_questions)
  
  should validate_presence_of(:keyword)
  
  should "return correct responses" do
    user = Factory(:user_with_auxs)
    org = Factory(:organization)
    Factory(:sms_keyword, user: user, organization: org, keyword: "Wat")
    
    assert_equal "Wat", SmsKeyword.last.to_s
    assert_equal "Wat (requested)", SmsKeyword.last.keyword_with_state
  end
  
  test "notify user" do
    user = Factory(:user_with_auxs)
    org = Factory(:organization)
    k = Factory(:sms_keyword, user: user, organization: org, keyword: "Wat")
    count = ActionMailer::Base.deliveries.count
    k.send(:notify_user)
    assert_equal count + 1, ActionMailer::Base.deliveries.count
  end
  
  test "notify user of denial" do
    user = Factory(:user_with_auxs)
    org = Factory(:organization)
    k = Factory(:sms_keyword, user: user, organization: org, keyword: "Wat")
    count = ActionMailer::Base.deliveries.count
    k.send(:notify_user_of_denial)
    assert_equal count + 1, ActionMailer::Base.deliveries.count
  end
end
