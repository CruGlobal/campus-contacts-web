hash = {
  'Infobase Sync' => {
    'class' => 'Jobs::InfobaseSync',
    'cron'  => '0 */4 * * *'
  },

  'Summer Missions Sync' => {
    'class' => 'Jobs::SummerMissionsSync',
    'cron'  => '0 */4 * * *'
  },

  'Contact assignment notifications' => {
    'class' => 'Jobs::ContactAssignmentNotifications',
    'cron'  => '0 0 * * *'
  },

  'Transfer notifications' => {
    'class' => 'Jobs::PersonTransferNotifications',
    'cron'  => '0 0 * * *'
  },

  # don't auto run the Mailchimp sync until we have done it once as a test
  # 'Mailchimp sync' => {
  #   'class' => 'MailChimpSyncWorker',
  #   'cron'  => '0 10 * * *',
  # }
}

Sidekiq::Cron::Job.load_from_hash! hash if Rails.env.production?
