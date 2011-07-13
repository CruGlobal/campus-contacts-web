class KeywordRequestMailer < ActionMailer::Base
  default from: "support@missionhub.com"
  layout 'email'
  
  def new_keyword_request(keyword)
    @keyword = keyword
    mail(to: 'programmers@cojourners.com',
         subject: 'New sms keyword request')
  end
  
  def notify_user(keyword)
    @keyword = keyword
    mail(to: keyword.user.person.email, subject: "Keyword '#{keyword}' was approved!")
  end
end
