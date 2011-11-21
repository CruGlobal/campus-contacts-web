class OrganizationMailer < ActionMailer::Base
  default from: "support@missionhub.com"
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
  
  def notify_user(org_id)
    @org = Organization.find(org_id)
    @admin = @org.admins.first
    mail(to: @admin.email, subject: "Organization '#{@org}' was approved!")
  end
  
  def notify_user_of_denial(org_id)
    @org = Organization.find(org_id)
    @admin = @org.admins.first
    mail(to: @admin.email, subject: "Organization '#{@org}' was rejected.")
  end
  
end
