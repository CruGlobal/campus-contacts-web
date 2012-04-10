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
end
