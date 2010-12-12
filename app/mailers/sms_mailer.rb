class SmsMailer < ActionMailer::Base
  default :from => "Cru <#{APP_CONFIG['from_email']}>"

  def text(to, msg, keyword)
    mail(:to => to, :from => "#{keyword.name} <#{APP_CONFIG['from_email']}>") do |format|
      format.text { render :text => msg }
    end
  end
end
