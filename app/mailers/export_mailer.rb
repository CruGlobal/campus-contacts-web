class ExportMailer < ActionMailer::Base
  default from: "\"#{ENV['SITE_TITLE']} Support\" <support@missionhub.com>",
          content_type: 'multipart/alternative',
          parts_order: ['text/html', 'text/enriched', 'text/csv']

  def send_csv(csv_string, person, organization)
    @person = person
    @organization = organization

    filename = "#{organization} - Contacts.csv"
    attachments[filename] = { mime_type: 'application/mymimetype', content: csv_string }

    mail to: @person.email, subject: "#{organization} Contacts"
  end
end
