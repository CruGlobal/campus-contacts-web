class KeywordRequestMailer < ActionMailer::Base
  default :from => "no-reply@campuscrusadeforchrist.com"
  layout 'email'
  
  def new_keyword_request(keyword)
    @keyword = keyword
    mail(:to => 'programmers@cojourners.com',
         :subject => 'New sms keyword request')
  end
end
