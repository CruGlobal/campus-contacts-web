module ApiHelper
  #########################################
  #######Matt's Validation Methods#########
  #########################################
  def valid_request?(request, in_action = nil, prms = nil, accesstoken = nil)
    begin
      #raise request.inspect
      #retrieve the API action requested so we can match the right allowed fields
      raise ApiErrors::InvalidRequest if request.try(:path_parameters).nil? && in_action.nil?
      #raise request.path_parameters["action"].inspect
      path_param_test = request.path_parameters["action"].nil? ? request.path_parameters[:action] : request.path_parameters["action"]
      action = in_action.nil? ?  path_param_test : in_action
      #Let's check to see if the fields query parameter is set first     
      param = prms.nil? ? params : prms
      if !param[:fields].nil?
        fields = param[:fields].split(',')
        raise ApiErrors::InvalidFieldError if fields.empty?
        #Let's validate the fields that they entered into the query params
        valid_fields = valid_fields?(fields, action)
        if valid_fields.length == fields.length
          raise ApiErrors::IncorrectScopeError unless valid_scope?(valid_fields, action, accesstoken).length == valid_fields.length 
        else raise ApiErrors::InvalidFieldError
        end
      else
        #if no fields supplied, check the scope for the action and go
        raise ApiErrors::IncorrectScopeError if valid_scope?(["all"], action, accesstoken).empty?
        valid_fields = Apic::API_ALLOWABLE_FIELDS[action.to_sym]
      end
      #rescue Exception => e 
      #render :json => {"error" => "#{e.message}"}, 
      #  :status => 404 and return
      #raise e.message
      #end
    end    
  valid_fields
  end
  
  def valid_fields?(fields,action)
    #return fields that are valid
     valid_fields = []
    if !Apic::API_ALLOWABLE_FIELDS[action.to_sym].nil?
      validator = Apic::API_ALLOWABLE_FIELDS[action.to_sym]
      valid_fields=[]
      fields.each do |field|
        valid_fields.push(field) if validator.include?(field)    #push all of the fields that match onto valid_fields array
      end
    end
    valid_fields
  end
  
  def valid_scope?(fields, action, access_token = nil)
    #return the fields that are in their allowed scope of those they requested
    access_token = Rack::OAuth2::Server.get_access_token(params[:access_token]) if access_token.nil?
    allowed_scopes = access_token.scope.to_s.split(' ')
    valid_fields_by_scope = []
    fields.each do |field|
      if Apic::SCOPE_REQUIRED[action.to_sym].has_key?(field)
        Apic::SCOPE_REQUIRED[action.to_sym][field].each do |scope|
          valid_fields_by_scope.push(field) if allowed_scopes.include?(scope)
        end
      end
    end
  valid_fields_by_scope
  end
end
