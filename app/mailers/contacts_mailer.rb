require 'vpim/vcard'
    
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
  
  def vcard(to, from, person_id)
    person = Person.find(person_id)
    @name = person.name
    filename = @name + '.vcf'
    subject = t('contacts.mailer.vcard_email_subject') + person.name

    attachments[filename] = person.vcard
    mail to: to, from: from, subject: subject
  end
  
  def bulk_vcard(to, from, book)
    filename = 'contacts.vcf'
    subject = t('contacts.mailer.bulk_vcard_email_subject')

    attachments[filename] = { mime_type: 'application/zip', content: book.to_s }
    mail to: to, from: from, subject: subject
  end
  
end
