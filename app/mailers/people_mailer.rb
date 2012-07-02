class PeopleMailer < ActionMailer::Base
  default from: "support@missionhub.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.people_mailer.bulk_message.subject
  #
  
  
  def notify_on_survey_answer(to, question_rule, keyword, answer)
    @keyword = keyword
    @answer = answer
    @answer_sheet = answer.answer_sheet
    @person = answer.answer_sheet.person
    @question = answer.question
    @question_rule = question_rule
    mail to: to, subject: "Someone answered \"#{@keyword.titleize}\" in your survey"
  end
  
  def bulk_message(to, from, subject, content)
    @content = content
    mail to: to, from: from, subject: subject
  end
  
  def self.queue
      :bulk_email
  end
end