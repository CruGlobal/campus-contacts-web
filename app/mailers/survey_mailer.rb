class SurveyMailer < ActionMailer::Base
  default from: "support@missionhub.com"

  def notify(to, person, answer)
    @person = person
    @answer = answer
    mail to: to, subject: "Survey Notification"
  end
  
end
