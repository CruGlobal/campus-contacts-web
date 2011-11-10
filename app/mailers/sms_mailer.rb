class SmsMailer < ActionMailer::Base
  @queue = :bulk_email

  def text(to, from, msg)
    from = from.present? ? from : APP_CONFIG['from_email']
    mail(to: to, from: from) do |format|
      format.text { render text: msg }
    end
  end
end
