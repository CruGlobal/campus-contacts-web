class SmsMailer < ActionMailer::Base
  default :from => "Cru <#{APP_CONFIG['from_email']}>"

  def text(to, msg, keyword)
    #changed #{keyword.name} => #{keyword.keyword}  Did not note "name" field in sms_keywords table
    mail(:to => to, :from => "#{keyword.keyword} <#{APP_CONFIG['from_email']}>") do |format|
      format.text { render :text => msg }
    end
  end
end
