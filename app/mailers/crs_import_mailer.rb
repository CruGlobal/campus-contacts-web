class CrsImportMailer < ActionMailer::Base
  default from: "support@missionhub.com"
  layout 'email'

  def failed(organization, email_address)
    @organization = organization
    mail to: email_address, subject: "Crs Import Failed"
  end

  def completed(organization, email_address)
    @organization = organization
    mail to: email_address, subject: "Crs Import Completed"
  end


end
