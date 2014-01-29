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
    email = Factory(:email_address, person: user.person)
    user.person.reload
    org = Factory(:organization)
    Factory(:sms_keyword, user: user, organization: org, keyword: "Wat")

    assert_equal "Wat", SmsKeyword.last.to_s
    assert_equal "Wat (requested)", SmsKeyword.last.keyword_with_state
  end

  test "notify user" do
    user = Factory(:user_with_auxs)
    Factory(:email_address, person: user.person)
    user.person.reload
    org = Factory(:organization)
    k = Factory(:sms_keyword, user: user, organization: org, keyword: "Wat")
    assert_difference("Sidekiq::Extensions::DelayedMailer.jobs.size", 1) do
      k.send(:notify_user)
    end
  end

  test "notify user of denial" do
    user = Factory(:user_with_auxs)
    Factory(:email_address, person: user.person)
    user.person.reload
    org = Factory(:organization)
    k = Factory(:sms_keyword, user: user, organization: org, keyword: "Wat")
    assert_difference("Sidekiq::Extensions::DelayedMailer.jobs.size", 1) do
      k.send(:notify_user_of_denial)
    end
  end
end
