source 'https://rubygems.org'

gem 'rails', '~> 3.2.2'
gem 'jquery-rails'
gem 'mysql2', '~> 0.3.11'
gem 'nokogiri'
gem 'json_pure'
gem 'redis'
gem 'rack-offline'
gem 'http_accept_language'
gem 'capistrano'
gem 'rest-client'
gem 'crack'
gem 'resque', '~> 1.20.0'
gem 'foreigner'
gem "devise", '1.5.1' #, git: "git://github.com/plataformatec/devise.git"
gem 'omniauth'
gem 'omniauth-facebook', '~> 1.0.0.rc2'
gem 'mini_fb'
gem 'client_side_validations'
gem 'rubycas-client', '~> 2.2.1'
gem 'rubycas-client-rails', '~> 0.1.0'
gem 'carmen', git: 'git://github.com/twinge/carmen.git'
gem 'ancestry'
gem 'activeadmin'#, git: 'git://github.com/gregbell/active_admin.git'
gem 'twilio-rb', git: 'git://github.com/stevegraham/twilio-rb.git'
gem "default_value_for"

gem 'dalli'
gem 'resque_mail_queue'

gem 'valium'
gem 'newrelic_rpm'#, '3.1.1'
gem "state_machine"
gem 'acts_as_list'
gem 'dynamic_form'
gem 'coffee-script'
gem 'trumant-rack-oauth2-server', git: 'git://github.com/twinge/rack-oauth2-server.git', branch: 'active_record'

gem 'enforce_schema_rules'
# gem 'sentient_user'
gem 'paper_trail', '~> 2'
gem 'unicorn'
gem 'airbrake_user_attributes'
gem 'cancan'
gem 'kaminari'
gem 'whenever'
gem "ransack", :git => "git://github.com/ernie/ransack.git"
gem 'deadlock_retry'
gem 'delegate_presenter'

gem 'vpim', git: 'git://github.com/twinge/vpim.git'   # vcard maker
gem 'i18n-js', git: 'git://github.com/fnando/i18n-js.git'     # allow i18n on js files 

gem 'rest-client'                                     # to make FB api requests
gem "paperclip", :git => 'git://github.com/thoughtbot/paperclip.git'
gem 'aws-sdk'#, '~> 1.3.4'

gem 'bitly'
gem 'copycopter_client'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'resque_unit'
  gem 'shoulda', :require => false
  # gem 'ephemeral_response'
  gem 'mocha'
  gem 'mailcatcher'
  gem 'factory_girl','~> 2.0.0.rc4'
  gem 'simplecov', '>= 0.3.5', require: false
  gem 'railroady'
  gem 'awesome_print'
  # Pretty printed test output
  # gem 'turn', :require => false
  gem 'rails-footnotes', '>= 3.7'
  # gem 'translate-rails3', :require => 'translate'
  gem 'ffaker'
  #gem 'ruby-debug19', :require => 'ruby-debug'

  gem 'webmock'#, '= 1.8.3'
end

group :development do
  gem 'rails-dev-tweaks'
end

group :performance do
  gem 'ruby-prof'
end

# Gems used only for assets and not required
# in production environments by default.
#gem 'sass-rails', "  ~> 3.1.0"
gem 'sass-rails', "~>3.2.3"
gem 'sass', '=3.1.14'
group :assets do
  gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier', ">= 1.0.3"
end
