class SmsMailer < ActionMailer::Base
  @queue = :bulk_email

  def text(to, from, msg, reply_to = nil)
    from = from.present? ? from : APP_CONFIG['from_email']
    if reply_to.present?
      mail(to: to, reply_to: reply_to, from: from, subject: '') do |format|
        format.text { render text: msg }
      end
    else
      mail(to: to, from: from, subject: '') do |format|
        format.text { render text: msg }
      end
    end
  end
end
