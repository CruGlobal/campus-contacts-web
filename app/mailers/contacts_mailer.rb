class ContactsMailer < ActionMailer::Base
  default from: "support@missionhub.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.contacts_mailer.reminder.subject
  #
  def reminder(to, from, subject, content)
    @content = content
    
    mail to: to, from: from, subject: subject
  end
  
end
