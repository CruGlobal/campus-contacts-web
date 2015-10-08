require 'test_helper'

class PeopleMailerTest < ActiveSupport::TestCase
  context 'notify_on_survey_answer' do
    setup do
      @rule = FactoryGirl.create(:rule)
      @element = FactoryGirl.create(:element)
      @survey = FactoryGirl.create(:survey)
      @person = FactoryGirl.create(:person)

      @survey_element = FactoryGirl.create(:survey_element, survey: @survey, element: @element, position: 1)
      @question_rule = FactoryGirl.create(:question_rule, rule: @rule, survey_element: @survey_element)
      @answer_sheet = FactoryGirl.create(:answer_sheet, person: @person, survey: @survey)
      @answer = FactoryGirl.create(:answer, answer_sheet: @answer_sheet, question: @element, value: 'ok')
    end

    should 'send notification' do
      PeopleMailer.notify_on_survey_answer('Sample <sample@email.com>', @question_rule.id, 'Testing1', @answer_sheet, @element.id).deliver_now
      content = ActionMailer::Base.deliveries.last
      assert_equal "Someone answered \"Testing1\" in your survey", content.subject
    end
  end

  context 'bulk_message' do
    setup do
      @person = FactoryGirl.create(:person)
    end

    should 'send bulk message' do
      PeopleMailer.bulk_message('vincent.paca@gmail.com', 'support@missionhub,com', 'subject', 'content').deliver_now
      content = ActionMailer::Base.deliveries.last
      assert_match /content/, content.body.to_s
    end

    should 'bulk message with reply_to' do
      PeopleMailer.bulk_message('vincent.paca@gmail.com', 'support@missionhub,com', 'subject', 'content', @person).deliver_now
      content = ActionMailer::Base.deliveries.last
      assert_match /content/, content.body.to_s
    end
  end
end
