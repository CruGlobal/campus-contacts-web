class KeywordRequestMailer < ActionMailer::Base
  default from: "\"#{ENV['SITE_TITLE']} Support\" <support@missionhub.com>"
  layout 'email'

  def new_keyword_request(keyword_id)
    @keyword = SmsKeyword.find(keyword_id)
    mail(to: 'support@missionhub.com',
         subject: 'New sms keyword request')
  end
end
