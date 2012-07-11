class LeaderMailer < ActionMailer::Base
  default from: "support@missionhub.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.leader_mailer.added.subject
  #
  def added(person, added_by, org, token)
    @person = person
    @added_by = added_by
    @org = org
    @token = token
    @from = if added_by.present? ? added_by.email : 'support@missionhub.com'
    mail to: person.email, from: @from, subject: "Missionhub.com - #{org}"
  end
end
