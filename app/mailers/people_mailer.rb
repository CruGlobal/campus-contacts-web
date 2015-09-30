class PeopleMailer < ActionMailer::Base
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper

  default from: "\"MissionHub Support\" <support@missionhub.com>"
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.people_mailer.bulk_message.subject
  #


  def notify_on_survey_answer(to, question_rule_id, keyword, answer_sheet, question_id)
    @keyword = keyword
    @answer_sheet = answer_sheet
    @person = @answer_sheet.person
    @question = Element.find(question_id)
    @question_rule = QuestionRule.find(question_rule_id)
    mail to: to, subject: "Someone answered \"#{@keyword.titleize}\" in your survey"
  end

  def bulk_message(to, from, subject, content, sender = nil)
    @content = simple_format(content)
    if sender.present?
      from = "\"#{sender.name}\" <#{from}>"
      mail from: from, to: to, reply_to: sender.email, subject: subject
    else
      mail from: from, to: to, subject: subject
    end
  end

  def notify_on_bulk_sms_failure(person, status, bulk_message, message)
    Rails.logger.debug(status.data)
    @person = person
    @status = status
    @message = message
    @bulk_message = bulk_message
    @failed = bulk_message.messages.includes(:receiver).where(sent: false)
    @failed_count = @failed.count

    mail to: @person.email, reply_to: @person.email, subject: "Failed Text Message Delivery"
  end

  def self.queue
      :bulk_email
  end
end