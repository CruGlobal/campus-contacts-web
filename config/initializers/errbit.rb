Airbrake.configure do |config|
  config.api_key = '1861fc3cefe5491a4223c2abe7b0bae4'
  config.host    = 'errors.uscm.org'
  config.port    = 80
  config.secure  = config.port == 443
  config.ignore << "ApiErrors::AccountSetupRequiredError"
  config.ignore << "ApiErrors::NoOrganizationError"
end
