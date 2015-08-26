hash = {
  'Infobase Sync' => {
    'class' => 'Jobs::InfobaseSync',
    'cron'  => '*/4 * * * *'
  },

  'Summer Missions Sync' => {
    'class' => 'Jobs::SummerMissionsSync',
    'cron'  => '*/4 * * * *'
  },

  'Contact assignment notifications' => {
    'class' => 'Jobs::ContactAssignmentNotifications',
    'cron'  => '0 0 * * *'
  },

  'Transfer notifications' => {
    'class' => 'Jobs::PersonTransferNotifications',
    'cron'  => '0 0 * * *'
  }
}

Sidekiq::Cron::Job.load_from_hash! hash
