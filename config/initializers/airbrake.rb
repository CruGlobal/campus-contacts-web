Airbrake.configure do |config|
  config.api_key = '030a0d01e3374fb88bb1ac1b3014d6b8'
  config.host    = 'api.rollbar.com'
  config.secure  = true
  config.ignore << "ApiErrors::AccountSetupRequiredError"
  config.ignore << "ApiErrors::NoOrganizationError"
end
