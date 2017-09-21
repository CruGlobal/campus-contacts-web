class OrganizationMailer < ActionMailer::Base
  default from: "\"#{ENV['SITE_TITLE']} Support\" <support@missionhub.com>"
  layout 'email'

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.organization_mailer.notify_admin_of_request.subject
  #
  def notify_admin_of_request(org_id)
    @org = Organization.find(org_id)
    @admin = @org.admins.first || Person.new
    mail(to: 'support@missionhub.com',
         subject: 'New organization request')
  end

  def notify_new_people(to, intro, new_people)
    @new_people = new_people
    @intro = intro
    mail to: to, subject: 'New Contact Notification'
  end
end
