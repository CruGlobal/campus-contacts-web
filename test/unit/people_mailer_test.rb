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
      PeopleMailer.notify_on_survey_answer("Sample <sample@email.com>", @question_rule, "Keyword", @answer).deliver
      content = ActionMailer::Base.deliveries.last
    end
    
    should "send notification if answer is hash" do
      PeopleMailer.notify_on_survey_answer("Sample <sample@email.com>", @question_rule, "Keyword", @answer.attributes).deliver
      content = ActionMailer::Base.deliveries.last
    end
    
  end
  
  test "bulk message" do
    PeopleMailer.bulk_message("vincent.paca@gmail.com", "support@missionhub,com", "subject", "content").deliver
    content = ActionMailer::Base.deliveries.last
    
    assert_match /content/, content.body.to_s
  end
end

