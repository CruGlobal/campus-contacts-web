class MailChimpSyncWorker
  include Sidekiq::Worker
  sidekiq_options unique: true

  CURRENT_USER_RANGE = 180.days.ago

  def perform(*)
    # Subscribe anyone who has logged in in the past [CURRENT_USER_RANGE] days
    active_users_not_subscribed
      .find_each { |u| User::MailChimpManager.new(u).subscribe }

    # Unsubscribe anyone who has NOT logged in in the past [CURRENT_USER_RANGE] days
    inactive_users_subscribed
      .find_each { |u| User::MailChimpManager.new(u).unsubscribe }
  end

  private

  def active_users_not_subscribed
    User.includes(person: [:primary_email_address, :organizational_permissions]).where('sign_in_count > 0')
      .where('current_sign_in_at > ?', CURRENT_USER_RANGE)
      .where(organizational_permissions: { permission_id: Permission::ADMIN_ID },
             subscribed_to_updates: nil)
  end

  def inactive_users_subscribed
    User.includes(person: :primary_email_address).where('sign_in_count > 0')
      .where('current_sign_in_at < ?', CURRENT_USER_RANGE)
      .where(subscribed_to_updates: true)
  end
end
