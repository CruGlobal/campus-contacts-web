User::MailChimpManager = Struct.new(:user) do
  def subscribe
    return unless user.person.present? && user_email.present? &&
                  user.person.first_name.present? && user.person.last_name.present?
    gb.lists(ENV.fetch('MAILCHIMP_LIST')).members(email_hash).upsert(body: subscribe_params)
    user.update_column(:subscribed_to_updates, true)
  rescue Gibbon::MailChimpError => e
    if self.class.invalid_email_error?(e)
      # For an invalid email address mark subscribed to updates as false so we
      # won't try it again (nil means not currently subscribed but try again)
      user.update_column(:subscribed_to_updates, false)
      return
    end
    raise
  end

  def unsubscribe
    return unless user_email.present?
    gb.lists(ENV.fetch('MAILCHIMP_LIST')).members(email_hash).delete

    # nil indicates that this user is not currently subscribed but could be
    # subscribed again if they sign into mpdx again.
    user.update_column(:subscribed_to_updates, nil)
  rescue Gibbon::MailChimpError => e
    if e.status_code == 404
      # Email address is already unsubscribed
      user.update_column(:subscribed_to_updates, nil)
      return
    end
    raise
  end

  def self.invalid_email_error?(e)
    e.status_code == 400 &&
    (e.message =~ /looks fake or invalid, please enter a real email/ ||
      e.message =~ /username portion of the email address is invalid/ ||
      e.message =~ /An email address must contain a single @/ ||
      e.message =~ /domain portion of the email address is invalid/)
  end

  private

  def subscribe_params
    {
      status_if_new: 'subscribed',
      email_address: user_email,
      merge_fields: { EMAIL: user_email, FNAME: user.person.first_name, LNAME: user.person.last_name }
    }
  end

  def gb
    @gb ||= Gibbon::Request.new(api_key: ENV.fetch('MAILCHIMP_KEY'))
  end

  def user_email
    user.person.email
  end

  def email_hash
    Digest::MD5.hexdigest(user_email.downcase)
  end
end
