require 'test_helper'

class KeywordRequestMailerTest < ActiveSupport::TestCase
  setup do
    user = FactoryGirl.create(:user_with_auxs)
    survey = FactoryGirl.create(:survey)
    FactoryGirl.create(:email_address, person: user.person)
    user.person.reload
    @keyword = FactoryGirl.create(:sms_keyword, user: user, organization: user.person.organizations.first, keyword: 'Wat', survey: survey)
  end

  test 'new keyword request' do
    KeywordRequestMailer.new_keyword_request(@keyword.id).deliver_now
    content = ActionMailer::Base.deliveries.last
    assert_match /New sms keyword request/, content.subject.to_s
  end
end
