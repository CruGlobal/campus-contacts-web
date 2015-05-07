class PeopleMailer < ActionMailer::Base
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper

  default from: "\"MissionHub Support\" <support@missionhub.com>"
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.people_mailer.bulk_message.subject
  #


  def notify_on_survey_answer(to, question_rule_id, keyword, answer_sheet_id, question_id)
    @keyword = keyword
    @answer_sheet = AnswerSheet.find(answer_sheet_id)
    @person = @answer_sheet.person
    @question = Element.find(question_id)
    @question_rule = QuestionRule.find(question_rule_id)
    mail to: to, subject: "Someone answered \"#{@keyword.titleize}\" in your survey"
  end

  def bulk_message(to, from, subject, content, reply_to = nil)
    @content = simple_format(content)
    if reply_to.present?
      mail to: to, reply_to: reply_to, from: from, subject: subject, content_type: "text/html"
    else
      mail to: to, from: from, subject: subject, content_type: "text/html"
    end
  end

  def notify_on_bulk_sms_failure(person, results, bulk_message, message)
    @person = person
    @results = results
    @message = message
    @bulk_message = bulk_message
    @sent_count = 0
    @failed_count = 0
    @results.each do |result|
      if result[:is_sent]
        @sent_count += 1
      else
        @failed_count += 1
      end
    end
    mail to: @person.email, reply_to: @person.email, subject: "Failed Text Message Delivery"
  end

  def self.queue
      :bulk_email
  end
end