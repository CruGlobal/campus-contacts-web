require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'rack/oauth2/server/admin'
require 'openssl'
# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Mh
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/app/presenters)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
     config.i18n.locale = :"en"
     config.i18n.default_locale = :"en"
     config.i18n.fallbacks = true

    # Please note that JavaScript expansions are *ignored altogether* if the asset
    # pipeline is enabled (see config.assets.enabled below). Put your defaults in
    # app/assets/javascripts/application.js in that case.
    #
    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(prototype prototype_ujs)

    #config.rubycas.cas_base_url = 'https://signin.relaysso.org/cas'
    #config.rubycas.logger = Rails.logger

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable IdentityMap for Active Record, to disable set to false or remove the line below.
    # config.active_record.identity_map = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.after_initialize do
      # integrate with devise
      config.oauth.authenticator = lambda do |email, password|
        user = User.find_for_database_authentication(email: email)
        user if user && user.valid_password?(password)
        user.id
      end

      #if evaluates to true then access_token can be granted, also required to be true for EVERY api call
      config.oauth.permissions_authenticator = lambda do |identity|
        org_memberships = User.find(identity).person.organizational_roles.leaders
        return true if !org_memberships.empty?
        false
      end

      config.oauth.param_authentication = true
      # config.oauth.authorization_types = %w{code}
      Rack::OAuth2::Server::Admin.set :client_id, "2"
      Rack::OAuth2::Server::Admin.set :client_secret, "e6f0bc02c1236f3d4cde6a4fd45e181569a8abf45ce17a3dba2fd88fe55722b6"
      Rack::OAuth2::Server::Admin.set :scope, %w{read write}
    end
  end

end
