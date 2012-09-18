class ImportMailer < ActionMailer::Base
  default from: "support@missionhub.com"

  def import_successful(user, table)
    @user = user
    @table = table
    mail to: user.person.email, subject: "Import complete"
  end

  def import_failed(user, errors)
    @user, @errors = user, errors
    mail to: user.person.email, subject: "Import failed"
  end
end
