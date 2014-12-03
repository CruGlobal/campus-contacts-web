class LeaderMailer < ActionMailer::Base
  default from: "\"MissionHub Support\" <support@missionhub.com>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.leader_mailer.added.subject
  #
  def added(person, added_by_id, org, token, permission_name)
    @person = person
    @added_by = Person.find(added_by_id)
    @org = org
    @token = token
    @permission_name = permission_name
    @from = @added_by.present? && @added_by.primary_email_address.present? ? @added_by.email : 'support@missionhub.com'

    if @person.user.present? && @person.email.present?
      @link = leader_link_url(@token, @person.user.id)
      mail to: @person.email, from: @from, subject: "Missionhub.com - #{@org}"
    end
  end

  def assignment(people_ids, assigned_to, assigned_by, org)
    @contacts = Person.where(id: people_ids)
    @assigned_to = assigned_to
    @assigned_by = assigned_by
    @organization = org
    if @assigned_by.present? && @assigned_by.primary_email_address.present?
      @from = @assigned_by.email
    else
      @from = 'support@missionhub.com'
    end
    if @assigned_to.email.present?
      mail to: @assigned_to.email, from: @from, subject: "Contact Assignment Notification"
    end
  end
end
