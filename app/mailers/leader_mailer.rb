class LeaderMailer < ActionMailer::Base
  default from: "support@missionhub.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.leader_mailer.added.subject
  #
  def added(person, added_by_id, org, token)
    @person = person
    @added_by = Person.find(added_by_id)
    @org = org
    @token = token
    @from = @added_by.present? && @added_by.primary_email_address.present? ? @added_by.email : 'support@missionhub.com'

    if @person.user.present?
      @link = leader_link_url(@token, @person.user.id)
      mail to: @person.email, from: @from, subject: "Missionhub.com - #{@org}"
    end
  end
end
