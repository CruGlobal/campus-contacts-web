require 'vpim/vcard'
    
class VcardMailer < ActionMailer::Base
  default from: "support@missionhub.com"
  
  def vcard(to, person_id, note = nil)
    @other_note = note
    person = Person.find(person_id)
    @name = person.to_s.titleize
    filename = @name + '.vcf'
    
    subject = t('contacts.mailer.vcard_email_subject', name: @name)

    attachments[filename] = Person.vcard(person_id).to_s
    mail to: to,  subject: subject
  end

  def bulk_vcard(to, ids, note = nil)
    @other_note = note
    
    filename = 'contacts.vcf'
    subject = t('contacts.mailer.bulk_vcard_email_subject')
    attachments[filename] = Person.vcard(ids.split).to_s

    mail to: to, subject: subject
  end
  
end