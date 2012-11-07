class PeopleMailer < ActionMailer::Base
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper

  default from: "support@missionhub.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.people_mailer.bulk_message.subject
  #
  
  
  def notify_on_survey_answer(to, question_rule, keyword, answer)
    @keyword = keyword
    @answer = answer.instance_of?(Hash) ? Answer.find(answer['id']) : answer
    @answer_sheet = @answer.answer_sheet
    @person = Person.last #answer.answer_sheet.person
    @question = @answer.question
    @question_rule = question_rule.instance_of?(Hash) ? QuestionRule.find(question_rule['id']) : question_rule
    mail to: to, subject: "Someone answered \"#{@keyword.titleize}\" in your survey"
  end
  
  def bulk_message(to, from, subject, content)
    @content = simple_format(content)
    mail to: to, from: from, subject: subject, content_type: "text/html"
  end
  
  def self.queue
      :bulk_email
  end
end