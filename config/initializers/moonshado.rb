require Rails.root.join('lib', 'moonshado-mass', 'moonshado-mass')
SMS = Moonshado::Sms.new(ENV.fetch('SMS_SHORT_CODE'), ENV.fetch('SMS_API_KEY'), ENV.fetch('SMS_DEFAULT_KEYWORD'), ENV.fetch('SMS_ENABLED'))
SMS.logger = Rails.logger
