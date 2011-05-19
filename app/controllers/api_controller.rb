class ApiController < ApplicationController
  skip_before_filter :authenticate_user!
  #before_filter {valid_request?(request)}
  oauth_required
  
  require 'Api_errors'
  include ApiErrors
  
  def user
    #valid_request? ensures that their request is a legal api request.  if error, spits out an error message
    valid_fields = valid_request?(request)
    if params[:id]=="me"
      user_id = oauth.identity
    else
      user_id = params[:id]
    end
 
    user = User.find_by_userID(user_id)
    raise ApiErrors::NoDataReturned unless user
    
    person = user.person
    
    api_call = {}
    #get their most recently authenticated facebook authorization entry
    @fb_id = user.authentications.where(:provider => "facebook").order("updated_at DESC").first.uid
    valid_fields.each do |x|
      case x
        when "id"
          api_call[x] = user.userID
        when "name"
          api_call[x] = "#{person.firstName} #{person.lastName}"
        when "first_name"
          api_call[x] = person.firstName
        when "last_name"
          api_call[x] = person.lastName
        when "gender" 
          api_call[x] = person.gender
        when "locale"
          api_call[x] = user.locale ? user.locale : ""
        when "lacation"
          api_call[x] = ""
        when "fb_id"
          api_call[x] = @fb_id
        when "birthday"
          api_call[x] = person.birth_date
        when "picture"
          api_call[x] = "http://graph.facebook.com/#{@fb_id}/picture"
        when "friends"
          api_call[x] = ""
        when "interests"
          api_call[x] = ""
      end
    end
    render :text => api_call.to_json
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
          #valid_request = true
        else 
          #valid_request = false
          raise ApiErrors::IncorrectScopeError
        end
      else
        #valid_request = false
        raise ApiErrors::InvalidFieldError
      end
    else
      #if no fields supplied, give them all that we allow
      valid_fields = validator
      if valid_scope?(valid_fields).length == valid_fields.length
        #valid_request = true
      else
        #valid_request = false
        raise ApiErrors::IncorrectScopeError
      end
    end
  valid_fields
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