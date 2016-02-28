class SurveyMailer < ActionMailer::Base
  default from: "\"#{ENV['SITE_TITLE']} Support\" <support@missionhub.com>"

  def notify(to, msg)
    @msg = msg
    mail to: to, subject: 'Survey Notification'
  end
end
