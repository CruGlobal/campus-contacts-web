source 'http://rubygems.org'

gem "default_value_for", '~> 2.0.3'
gem "devise", '~> 2.1.0' #, git: "http://github.com/plataformatec/devise.git"
gem "paperclip", :git => 'http://github.com/thoughtbot/paperclip.git', :ref => '52840dcd9d87708eccded7477221c5420761e085'
gem "ransack", :git => "http://github.com/ernie/ransack.git", ref: 'c7c4e46dc19fe6f755183a6da39fcb82a265ed10'
gem "state_machine", '~> 1.1.2'
gem "strip_attributes", '~> 1.4.4'
gem 'active_model_serializers'#, git: 'http://github.com/josevalim/active_model_serializers.git'
gem 'activeadmin', '~> 0.4.4' #, git: 'http://github.com/gregbell/active_admin.git'
gem 'acts_as_list', '~> 0.3.0'
gem 'airbrake', '~> 3.1.14'
gem 'ancestry', git: 'http://github.com/stefankroes/ancestry.git'
gem 'aws-sdk', '1.8.1.3'
gem 'bitly', '~> 0.9.0'
gem 'bluepill', '0.0.60', require: false
gem 'cancan', '~> 1.6.10'
gem 'capistrano', '~> 3.0.0'
gem 'carmen', git: 'http://github.com/twinge/carmen.git'
gem 'client_side_validations', '~> 3.2.6'
gem 'copycopter_client', '~> 2.0.1'
gem 'crack', '~> 0.3.2'
gem 'dalli', '~> 2.6.4'
gem 'deadlock_retry', '~> 1.2.0'
gem 'delegate_presenter', '~> 0.0.2'
gem 'dynamic_form', '~> 1.1.4'
gem 'enforce_schema_rules', '~> 0.0.17'
gem 'foreigner', '~> 1.5.0'
gem 'http_accept_language', '~> 2.0.0'
gem 'i18n-js' #, git: 'http://github.com/fnando/i18n-js.git'     # allow i18n on js files
gem 'kaminari', '~> 0.14.1'
gem 'libv8', '=3.11.8.17'
gem 'mini_fb', '~> 2.0.0'
gem 'mysql2', '~> 0.3.11'
gem 'newrelic_rpm', '>= 3.5.3.25'
gem 'nokogiri', '~> 1.6.0'
gem 'oj', '~> 2.1.7'
gem 'omniauth', '~> 1.1.1'
gem 'omniauth-cas'
gem 'omniauth-facebook', '1.4.0'
gem 'paper_trail', '~> 2.7.2'
gem 'rack-offline', '~> 0.6.4'
gem 'rails', '~> 3.2.15'
gem 'rails_autolink', '~> 1.1.4'
gem 'redis', '~> 3.0.5'
gem 'sidekiq', '~> 2.15.2'
gem 'sidekiq-failures', '~> 0.3.0'
gem 'sinatra', '>= 1.3.0', :require => nil
gem 'rest-client', '~> 1.6.7'                                     # to make FB api requests
gem 'retryable-rb', '~> 1.1.0'
#gem 'rubycas-client', '~> 2.2.1'
#gem 'rubycas-client-rails', '~> 0.1.0'
gem 'trumant-rack-oauth2-server', git: 'http://github.com/twinge/rack-oauth2-server.git', branch: 'active_record'
gem 'twilio-rb', git: 'http://github.com/stevegraham/twilio-rb.git', ref: 'fad1e27e2e3a3df84f6c15a42e1eab1c69deae7b'
gem 'unicorn', '~> 4.6.3'
gem 'valium', '~> 0.5.0'
gem 'versionist', '~> 1.0.0'
gem 'vpim', git: 'http://github.com/twinge/vpim.git'   # vcard maker
gem 'whenever', '~> 0.8.4'
gem 'wiser_date', '~> 0.3.0'
gem 'wiser_timezone', '~> 0.1.9'
gem 'infobase', '~> 1.0.0'
gem 'multi_json', '~> 1.8.2'
gem 'sp_client', '~> 1.0.2'


group :development, :test do
  gem 'guard', '~> 1.8.2'
  gem 'guard-test', '~> 1.0.0'
  gem 'awesome_print', '~> 1.2.0'
  gem 'quiet_assets', '~> 1.0.2'
end

group :test do
  gem 'webmock'#, '= 1.8.3'
  gem 'factory_girl','~> 2.0.0.rc4'
  gem 'simplecov', '>= 0.3.5', require: false
  #gem 'resque_unit'
  gem 'shoulda', :require => false
  gem 'mocha', :require => false
  gem 'ffaker', '~> 1.20.0'
end

group :development do
  #gem 'rails-dev-tweaks'
  gem 'rack-mini-profiler'
  gem 'rails-footnotes', '~> 3.7.9'
  gem 'bullet', '~> 4.6.0'
  gem 'travis-lint', '~> 1.7.0'
  gem 'mailcatcher', '~> 0.5.12'
  gem 'railroady', '~> 1.1.1'
  #gem 'localeapp'
  gem "better_errors", ">= 0.7.2"
  #gem "binding_of_caller"
end

group :performance do
  gem 'ruby-prof', '~> 0.13.0'
end

# Gems used only for assets and not required
# in production environments by default.
#gem 'sass-rails', "  ~> 3.1.0"
group :assets do
  gem 'therubyracer',           '~> 0.11.4'
  gem 'coffee-rails',           "~> 3.2.1"
  gem 'uglifier',               ">= 1.0.3"
  gem 'coffee-script',          '~> 2.2.0'
  gem 'jquery-rails',           '~> 3.0.4'

  gem 'sass',                   "~> 3.2.12"
  gem 'sass-rails',             "~> 3.2.3"
  gem "compass",                '~> 0.12.2'
  gem "compass-rails",          '~> 1.1.2'
  gem "compass-normalize",      '~> 1.4.3'
  gem 'susy',                   '~> 1.0.9'
  gem 'bootstrap-sass',         '~> 3.1.0'
end

group :capistrano do
  # Shared capistrano recipes
  #gem 'pd-cap-recipes', :git => 'http://github.com/PagerDuty/pd-cap-recipes.git'

  # extra dependencies for some tasks
  #gem 'git', '1.2.5'
  #gem 'cap_gun'
  #gem 'grit'
end
