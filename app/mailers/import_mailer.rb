class ImportMailer < ActionMailer::Base
  default from: "support@missionhub.com"

  def import_successful(user)
    @user = user
    mail to: user.person.email, subject: "Import complete"
  end

  def import_failed(user, errors)
    @user, @errors = user, errors
    mail to: user.person.email, subject: "Import failed"
  end
end
