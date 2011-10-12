class PeopleMailer < ActionMailer::Base
  default from: "support@missionhub.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.people_mailer.bulk_message.subject
  #
  def bulk_message(to, from, subject, content)
    @content = content

    mail to: to, from: from, subject: subject
  end
  
  
  def self.queue
      :bulk_email
  end
end