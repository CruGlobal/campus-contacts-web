class DigestMailerWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(*)
    active_admins.each do |admin|
      next if admin.notification_settings&.dig('weekly_digest') == false
      ReportMailer.leader_digest(admin.person.id).deliver_later
    end
  end

  private

  def active_admins
    User.includes(person: [:organizational_permissions])
      .where('sign_in_count > 0')
      .where(organizational_permissions:
               { permission_id: Permission::ADMIN_ID, archive_date: nil, deleted_at: nil }
            )
  end
end
