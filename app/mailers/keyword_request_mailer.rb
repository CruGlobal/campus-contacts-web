class KeywordRequestMailer < ActionMailer::Base
  default :from => "no-reply@campuscrusadeforchrist.com"
  layout 'email'
  
  def new_keyword_request(keyword_request)
    @keyword_request = keyword_request
    mail(:to => 'programmers@cojourners.com',
         :subject => 'New keyword request')
  end
end
