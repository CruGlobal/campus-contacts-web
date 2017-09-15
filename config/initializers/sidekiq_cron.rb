daily = '0 0 * * *'
every_6_hours = '0 */4 * * *'
just_after_midnight = '0 10 * * *'

hash = {
  'Infobase Sync' => {
    'class' => 'Jobs::InfobaseSync',
    'cron'  => every_6_hours
  },

  'Summer Missions Sync' => {
    'class' => 'Jobs::SummerMissionsSync',
    'cron'  => every_6_hours
  },

  'Contact assignment notifications' => {
    'class' => 'Jobs::ContactAssignmentNotifications',
    'cron'  => daily
  },

  'Transfer notifications' => {
    'class' => 'Jobs::PersonTransferNotifications',
    'cron'  => daily
  },

  'Mailchimp sync' => {
    'class' => 'MailChimpSyncWorker',
    'cron'  => just_after_midnight
  }
}

Sidekiq::Cron::Job.load_from_hash! hash if Rails.env.production?
