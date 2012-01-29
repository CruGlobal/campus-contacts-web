class SurveyMailer < ActionMailer::Base
  default from: "support@missionhub.com"

  def notify(to, msg)
    @msg = msg
    mail to: to, subject: "Survey Notification"
  end
  
end
