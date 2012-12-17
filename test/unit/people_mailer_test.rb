require 'test_helper'

class PeopleMailerTest < ActiveSupport::TestCase

  context "notify_on_survey_answer" do
    setup do
      @rule = Factory(:rule)
      @element = Factory(:element)
      @survey = Factory(:survey)
      @person = Factory(:person)

      @survey_element = Factory(:survey_element, survey: @survey, element: @element, position: 1)
      @question_rule = Factory(:question_rule, rule: @rule, survey_element: @survey_element)
      @answer_sheet = Factory(:answer_sheet, person: @person, survey: @survey)
      @answer = Factory(:answer, answer_sheet: @answer_sheet, question: @element, value: 'ok')
    end

    should "send notification" do
      PeopleMailer.notify_on_survey_answer("Sample <sample@email.com>", @question_rule.id, "Testing1", @answer.id).deliver
      content = ActionMailer::Base.deliveries.last
      assert_equal "Someone answered \"Testing1\" in your survey", content.subject
    end

  end

  test "bulk message" do
    PeopleMailer.bulk_message("vincent.paca@gmail.com", "support@missionhub,com", "subject", "content").deliver
    content = ActionMailer::Base.deliveries.last

    assert_match /content/, content.body.to_s
  end
end

