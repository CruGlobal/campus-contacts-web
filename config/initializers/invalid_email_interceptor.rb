class BouncedEmailInterceptor
  def self.delivering_email(message)
    suppressed_emails = EmailResponse.where(email: message.to).pluck(:email)

    if (message.to - suppressed_emails).none?
      message.perform_deliveries = false
    else
      message.to -= suppressed_emails
    end
  end
end

ActionMailer::Base.register_interceptor(BouncedEmailInterceptor)
