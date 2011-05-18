class ApiController < ApplicationController
  skip_before_filter :authenticate_user!
  before_filter {valid_request?(request)}
  oauth_required
  
  require 'Api_errors'
  include ApiErrors
  
  def me
    user = User.find_by_userID(oauth.identity)
    person = user.person
    #raise user.to_json
    render :text => user.to_json
  end
  
  def user
    
  end
  
  def schools
    result = School.select("targetAreaID, name, address1, city, state, zip").where('name LIKE ?', "%#{params[:term]}%").limit(100)
    render :text => result.to_json
  end
  
  def valid_request?(request)
    #retrieve the API action requested so we can match the right allowed fields
    action = request.path_parameters[:action]
    case action
      when "me"
        validator = Apic::API_ALLOWABLE[:user]
      when "user"
        validator = Apic::API_ALLOWABLE[:user]
      when "schools"
      else 
        validator = Apic::API_ALLOWABLE[:user]
        raise ApiErrors::InvalidRequest
    end
    
    #Let's check to see if the fields query parameter is set first     
    if params[:fields]
      fields = params[:fields].split(',')
      
      valid_fields = valid_fields?(fields,validator)
      if valid_fields.length == fields.length
        if valid_scope?(valid_fields).length == valid_fields.length 
          valid_request = true
        else 
          valid_request = false
          raise ApiErrors::IncorrectScopeError
        end
      else
        valid_request = false
        raise ApiErrors::InvalidFieldError
      end
    else
      #if no fields supplied, give them all that we allow
      valid_fields = validator
      if valid_scope?(valid_fields).length == valid_fields.length
        valid_request = true
      else
        valid_request = false
        raise ApiErrors::IncorrectScopeError
      end
    end
  valid_request
  end
  
  def valid_fields?(fields,validator)
    #return fields that are valid
    valid_fields=[]
    fields.each do |field|
      validator.each do |x|
        if (x.eql?(field)) != false
          valid_fields.push(field)    #push all of the fields that match onto valid_fields array
          break
        end
      end
    end
    valid_fields
  end
  
  def valid_scope?(fields)
    #return the fields that are in their allowed scope of those they requested
    allowed_scopes = (Rack::OAuth2::Server.get_access_token(params[:access_token]).scope).split(' ')
    valid_fields_by_scope = []
    fields.each do |field|
      allowed_scopes.each do |x|
        if (Apic::SCOPE_REQUIRED[field].first.eql?(x))
          valid_fields_by_scope.push(field)
          break
        end
      end
    end
    valid_fields_by_scope
  end   
end