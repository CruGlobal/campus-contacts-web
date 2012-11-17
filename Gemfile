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
gem 'activeadmin', '~> 0.4.4' #, git: 'git://github.com/gregbell/active_admin.git'
gem 'twilio-rb', git: 'git://github.com/stevegraham/twilio-rb.git'
gem "default_value_for"
gem 'turbo-sprockets-rails3'
gem "strip_attributes"

gem 'dalli'
gem 'resque_mail_queue'

gem 'valium'
gem 'newrelic_rpm'#, '3.1.1'
gem "state_machine"
gem 'acts_as_list'
gem 'dynamic_form'
gem 'coffee-script'
gem 'trumant-rack-oauth2-server', git: 'git://github.com/twinge/rack-oauth2-server.git', branch: 'active_record'
gem 'rails_autolink'

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

gem 'active_model_serializers', git: 'git://github.com/josevalim/active_model_serializers.git'
gem 'versionist', git: 'git://github.com/twinge/versionist.git', branch: 'multiple_versioning_strategies'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  gem 'awesome_print'
end

group :test do
  gem 'webmock'#, '= 1.8.3'
  gem 'factory_girl','~> 2.0.0.rc4'
  gem 'simplecov', '>= 0.3.5', require: false
  gem 'autotest-rails'
  gem 'resque_unit'
  gem 'shoulda', :require => false
  gem 'mocha'
  gem 'ffaker'
end

group :development do
  gem 'rails-dev-tweaks'
  gem 'rails-footnotes'
  gem 'bullet'
  gem 'mailcatcher'
  gem 'railroady'
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

group :capistrano do 
  # Shared capistrano recipes
  gem 'pd-cap-recipes', :git => 'git://github.com/PagerDuty/pd-cap-recipes.git'

  # extra dependencies for some tasks
  #gem 'git', '1.2.5'
  #gem 'cap_gun'
  #gem 'grit'
end
