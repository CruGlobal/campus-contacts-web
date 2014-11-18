class CrsImportMailer < ActionMailer::Base
  default from: "\"MissionHub Support\" <support@missionhub.com>"
  layout 'email'

  def failed(organization, email_address)
    @organization = organization
    mail to: email_address, subject: "CRS Import Failed"
  end

  def completed(organization, email_address)
    @organization = organization
    mail to: email_address, subject: "CRS Import Completed"
  end
end
