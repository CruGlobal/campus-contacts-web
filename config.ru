# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
require 'FacebookMobileOmniauth.rb'
#use Rack::FacebookMobileOmniauth 
run Ma::Application
