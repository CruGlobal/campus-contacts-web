require Rails.root.join('lib', 'moonshado-mass', 'moonshado-mass')
SMS = Moonshado::Sms.new(APP_CONFIG['sms_short_code'], APP_CONFIG['sms_api_key'], APP_CONFIG['sms_default_keyword'], APP_CONFIG['sms_enabled'])
SMS.logger = Rails.logger
