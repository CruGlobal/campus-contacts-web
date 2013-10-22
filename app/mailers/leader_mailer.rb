class LeaderMailer < ActionMailer::Base
  default from: "support@missionhub.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.leader_mailer.added.subject
  #
  def added(person_id, added_by_id, org_id, token)
    @person = Person.find(person_id)
    @added_by = Person.find(added_by_id)
    @org = Organization.find(org_id)
    @token = token
    @from = @added_by.present? && @added_by.primary_email_address.present? ? @added_by.email : 'support@missionhub.com'
    mail to: @person.email, from: @from, subject: "Missionhub.com - #{@org}"
  end
end
