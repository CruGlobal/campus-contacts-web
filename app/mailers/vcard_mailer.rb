require 'vpim/vcard'
    
class VcardMailer < ActionMailer::Base
  default from: "support@missionhub.com"
  
  def vcard(to, person_id)
    person = Person.find(person_id)
    @name = person.name
    filename = @name + '.vcf'
    subject = t('contacts.mailer.vcard_email_subject') + person.name

    attachments[filename] = person.vcard
    mail to: to,  subject: subject
  end

  def bulk_vcard(to, book)
    filename = 'contacts.vcf'
    subject = t('contacts.mailer.bulk_vcard_email_subject')

    attachments[filename] = { mime_type: 'application/zip', content: book.to_s }
    mail to: to, subject: subject
  end
  
end