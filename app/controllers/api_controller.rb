class ApiController < ApplicationController  
  extend ::Rack::OAuth2::Rails::Filters
  require 'api_errors'
  include ApiErrors
  require 'api_helper'
  include ApiHelper
  skip_before_filter :authenticate_user!
  after_filter :logApiRequest
  rescue_from Exception, with: :render_json_error
  
#################################################################################
#####CODE FROM http://www.starkiller.net/2011/03/17/versioned-api-1/  ###########
#################################################################################
  @@versions = {}
  @@registered_methods = {}

  class << self
    alias_method :original_inherited, :inherited
    def inherited(subclass)
      original_inherited(subclass)
    
      load File.join("#{Rails.root}", "app", "controllers", 
                     "api", "#{extract_filename(subclass)}")

      subclass.action_methods.each do |method|
        regex = Regexp.new("^(.*)_(\\d+)$")
        if match = regex.match(method)
          key = "#{subclass.to_s}##{match[1]}"
          if match[2].to_i <= Apic::STD_VERSION
            @@versions[match[2].to_i] = true
            @@registered_methods[key] ||= {}
            @@registered_methods[key][match[2].to_i] = true
      
            subclass.instance_eval do
              define_method(match[1].to_sym) {}
            end
          end
        end
      end
      subclass.reset_action_methods
    end
  
    def extract_filename(subclass)
      classname = subclass.to_s.split('::')[1]
      parts = classname.underscore.split('_')
      "#{parts.reject{|c| c == 'controller'}.join('_')}_controller.rb"
    end

    def reset_action_methods
      @action_methods = nil
      action_methods
    end
  end
  
  
  def versions
    render json: @@versions.keys.sort.reverse and return
  end

  def no_api_method
    render json: {"error" => "The requested method does not exist or is not\
       enabled for the requested API version (v#{params[:version]})"}, 
       status: 404 and return
  end


  private
  def protected_actions
    ['versions','no_api_method']
  end

  alias_method :original_process_action, :process_action
  def process_action(method_name, *args)
    method = "no_api_method"
    if protected_actions.include? method_name
      method = method_name
    else
      if params[:version]
        params[:version] = params[:version][1..-1].to_i
      else
        default_version = @@versions.keys.max
        pattern = /application\/vnd\.missionhub-v(\d+)\+.*/
        # pattern = /application\/vnd\.com\.example\.api\.v([\d\.]+)\+.*/
        params[:version] = (request.env['HTTP_ACCEPT'][pattern, 1] || default_version).to_i
      end
      method = find_method(method_name, params[:version])
    end
    original_process_action(method, *args)
  end

  def find_method(method_name, version)
    key = "#{self.class.to_s}##{method_name}"
    versions = @@registered_methods[key].keys.sort
  
    final_method = 'no_api_method'

    versions.reverse.each do |v|
      if v <= version
        final_method = "#{method_name}_#{v}"
        break
      end
    end
  
    final_method
  end
end