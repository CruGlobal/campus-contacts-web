class LeaderMailer < ActionMailer::Base
  default from: "\"#{ENV['SITE_TITLE']} Support\" <support@missionhub.com>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.leader_mailer.added.subject
  #
  def added(person, added_by_id, org, token, permission_name)
    @person = person
    @added_by = Person.find_by(id: added_by_id)
    @org = org
    @token = token
    @permission_name = permission_name

    if @person.user.present? && @person.email.present?
      @link = leader_link_url(@token, @person.user.id)
      mail to: @person.email_addresses.pluck(:email), subject: "Missionhub.com - #{@org}"
    end
  end

  def assignment(people_ids, assigned_to, assigned_by, org)
    @contacts = Person.where(id: people_ids)
    @assigned_to = assigned_to
    @assigned_by = assigned_by
    @organization = org
    if @assigned_to.email.present?
      mail to: @assigned_to.email, subject: 'Contact Assignment Notification'
    end
  end

  def assignments(leader, org, assignment_array)
    @assigned_to = leader
    @organization = org
    @assignment_array = assignment_array
    if @assigned_to.email.present?
      mail(to: @assigned_to.email, subject: 'Contact Assignments Notification')
    end
  end

  def resend(email, requested_by)
    @requested_by_name = requested_by.person.try(:name) || requested_by.username
    @person = email.person
    user = @person.user
    return unless user.present?
    user.generate_new_token if user.remember_token.blank? || user.remember_token_expires_at.nil? || user.remember_token_expires_at < Date.tomorrow
    @link = leader_link_url(user.remember_token, user.id)
    mail to: email.email, subject: 'Missionhub.com - Email Confirmation'
  end
end
