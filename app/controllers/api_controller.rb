class ApiController < ApplicationController  
  require 'Api_errors'
  include ApiErrors
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
          @@versions[match[2].to_i] = true
          @@registered_methods[key] ||= {}
          @@registered_methods[key][match[2].to_i] = true
      
          subclass.instance_eval do
            define_method(match[1].to_sym) {}
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
    render :json => @@versions.keys.sort.reverse and return
  end

  def no_api_method
    render :json => {"error" => "The requested method does not exist or is not\
       enabled for the requested API version (v#{params[:version]})"}, 
       :status => 404 and return
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
        params[:version] = params[:version][1,params[:version].length - 1].to_i
      else
        params[:version] = @@versions.keys.max
      end
      method = find_method(method_name, params[:version])
    end
    #method = "no_api_method" unless valid_request?(request)
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
  # 
  # #########################################
  # #######Matt's Validation Methods#########
  # #########################################
  # 
  # def valid_request?(request, in_action = nil)
  #   begin
  #     #retrieve the API action requested so we can match the right allowed fields
  #     action = in_action.nil? ? request.path_parameters[:action] : in_action
  #     # case action
  #     #  when "user"
  #     #    validator = Apic::API_ALLOWABLE_FIELDS[:user]
  #     #  when "friends"
  #     #    validator = Apic::API_ALLOWABLE_FIELDS[:friends]
  #     #  else 
  #     #    raise ApiErrors::InvalidRequest
  #     #  end
  # 
  #     #Let's check to see if the fields query parameter is set first     
  #     if params[:fields]
  #       fields = params[:fields].split(',')
  #       
  #       #Let's validate the fields that they entered into the query params
  #       valid_fields = valid_fields?(fields, action)
  #       if valid_fields.length == fields.length
  #         raise ApiErrors::IncorrectScopeError unless valid_scope?(valid_fields).length == valid_fields.length 
  #       else raise ApiErrors::InvalidFieldError
  #       end
  #     else
  #       #if no fields supplied, check the scope for the action and go
  #       raise ApiErrors::IncorrectScopeError unless true #valid_scope?(nil, action)
  #       valid_fields = Apic::API_ALLOWABLE_FIELDS[action.to_sym]
  #     end
  #  # rescue Exception => e 
  #   #  render :json => {"error" => "#{e.message}"}, 
  #   #  :status => 404 and return
  #   end    
  # valid_fields
  # end
  # 
  # def valid_fields?(fields,action)
  #   #return fields that are valid
  #   validator = [] unless Apic::API_ALLOWABLE_FIELDS[action.to_sym]
  #   valid_fields=[]
  #   fields.each do |field|
  #     valid_fields.push(field) if validator.include?(field)    #push all of the fields that match onto valid_fields array
  #   end
  #   valid_fields
  # end
  # 
  # def valid_scope?(fields, action)
  #   #return the fields that are in their allowed scope of those they requested
  #   allowed_scopes = Rack::OAuth2::Server.get_access_token(params[:access_token])
  #   allowed_scopes = allowed_scopes.scope.to_s.split(' ')
  #   
  #   valid_fields_by_scope = []
  #   if fields.nil?
  #     Apic::SCOPE_REQUIRED[action.to_sym]["all"].each do |scope|
  #       if allowed_scopes.include?(scope)
  #         valid_fields_by_scope = true
  #         break
  #       end
  #     end
  #   else
  #     fields.each do |field|
  #       if Apic::SCOPE_REQUIRED[action.to_sym].has_key?(field)
  #         Apic::SCOPE_REQUIRED[action.to_sym][field].each do |scope|
  #           valid_fields_by_scope.push(field) if allowed_scopes.include?(scope)
  #         end
  #       end
  #     end
  #     valid_fields_by_scope
  #   end
  # end

end