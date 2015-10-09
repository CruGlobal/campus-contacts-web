class SmsMailer < ActionMailer::Base
  def text(to, from, msg, reply_to = nil)
    from = from.present? ? from : ENV.fetch('FROM_EMAIL')
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
