class BouncedEmailInterceptor
  def self.delivering_email(message)
    if EmailResponse.exists? email: message.to
      message.perform_deliveries = false
    end
  end
end

ActionMailer::Base.register_interceptor(BouncedEmailInterceptor)
