top_of_every_hour = '0 0 * * *'
every_15_minutes = '0 */4 * * *'
ten_minutes_past_the_hour = '0 10 * * *'
sunday_morning = '10 7 * * 7'

hash = {
  'Infobase Sync' => {
    'class' => 'Jobs::InfobaseSync',
    'cron'  => every_15_minutes
  },

  'Summer Missions Sync' => {
    'class' => 'Jobs::SummerMissionsSync',
    'cron'  => every_15_minutes
  },

  'Contact assignment notifications' => {
    'class' => 'Jobs::ContactAssignmentNotifications',
    'cron'  => top_of_every_hour
  },

  'Transfer notifications' => {
    'class' => 'Jobs::PersonTransferNotifications',
    'cron'  => top_of_every_hour
  },

  'Mailchimp sync' => {
    'class' => 'MailChimpSyncWorker',
    'cron'  => ten_minutes_past_the_hour
  },

  'Mega farmer report' => {
    'class' => 'MegaFarmerReportWorker',
    'cron'  => sunday_morning
  }
}

Sidekiq::Cron::Job.load_from_hash! hash if Rails.env.production?
