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
    user = FactoryGirl.create(:user_with_auxs)
    email = FactoryGirl.create(:email_address, person: user.person)
    user.person.reload
    org = FactoryGirl.create(:organization)
    FactoryGirl.create(:sms_keyword, user: user, organization: org, keyword: "Wat")

    assert_equal "Wat", SmsKeyword.last.to_s
    assert_equal "Wat (requested)", SmsKeyword.last.keyword_with_state
  end

  test "notify user" do
    user = FactoryGirl.create(:user_with_auxs)
    FactoryGirl.create(:email_address, person: user.person)
    user.person.reload
    org = FactoryGirl.create(:organization)
    k = FactoryGirl.create(:sms_keyword, user: user, organization: org, keyword: "Wat")
    assert_difference("Sidekiq::Extensions::DelayedMailer.jobs.size", 1) do
      k.send(:notify_user)
    end
  end

  test "notify user of denial" do
    user = FactoryGirl.create(:user_with_auxs)
    FactoryGirl.create(:email_address, person: user.person)
    user.person.reload
    org = FactoryGirl.create(:organization)
    k = FactoryGirl.create(:sms_keyword, user: user, organization: org, keyword: "Wat")
    assert_difference("Sidekiq::Extensions::DelayedMailer.jobs.size", 1) do
      k.send(:notify_user_of_denial)
    end
  end
end
