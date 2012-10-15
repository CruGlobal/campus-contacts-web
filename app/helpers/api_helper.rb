require 'apic.rb'
require 'api_errors.rb'

module ApiHelper
  include ApiErrors
  #########################################
  #######Validation Methods################
  #########################################
  
  def valid_request_before
    @valid_fields = valid_request?(request)
  end
  
  def valid_request?(request) #, in_action = nil, prms = nil, accesstoken = nil
    #retrieve the API action requested so we can match the right allowed fields
    raise ApiErrors::InvalidRequest if request.params[:action].nil?# && in_action.nil?
    
    # action = in_action.nil? ?  request.params[:action] : in_action
    action = request.params[:controller].split("/").last
    param = request.params #prms.nil? ? params : prms
    
    #Handle versioning of API in Apic class
    version = param[:version].to_i > Apic::STD_VERSION ? Apic::STD_VERSION : param[:version]
    version = ["v", version.to_s].join
    
    #Let's check to see if the fields query parameter is set first   
    if !param[:fields].nil?
      fields = param[:fields].split(',')
      raise ApiErrors::InvalidFieldError if fields.empty?
      #Let's validate the fields that they entered into the query params
      valid_fields = valid_fields?(fields, action, version)
    else
      #if no fields supplied, send all
      valid_fields = Apic::API_ALLOWABLE_FIELDS[version.to_sym][action.to_sym]
    end
    valid_fields
  end
  
  def valid_fields?(fields,action,version)
    #return fields that are valid
     valid_fields = []
    if Apic::API_ALLOWABLE_FIELDS[version.to_sym][action.to_sym].present?
      valid_fields = fields & Apic::API_ALLOWABLE_FIELDS[version.to_sym][action.to_sym]
    end
    raise "#{action} -- #{version}" if valid_fields.empty?
    valid_fields
  end
 
  def organization_allowed?   
    if (params[:org].present? || params[:org_id].present?)
      raise ApiErrors::OrganizationNotIntegerError unless (is_int?(params[:org_id]) || is_int?(params[:org])) 
      org_id = params[:org].present? ? params[:org].to_i : params[:org_id].to_i
      raise ApiErrors::OrgNotAllowedError unless valid_org_ids.include?(org_id)
    elsif params[:keyword].present?
      @valid_key_ids = valid_keywords.collect(&:id)
      raise ApiErrors::OrgNotAllowedError unless @valid_key_ids.include?(params[:keyword])
    elsif params[:keyword_id].present?
      raise ApiErrors::KeywordNotIntegerError unless is_int?(params[:keyword_id]) 
      @valid_key_names = valid_keywords.collect(&:keyword)
      raise ApiErrors::OrgNotAllowedError unless @valid_key_names.include?(params[:keyword])
    end
  true
  end
  
  def valid_org_ids
    # @valid_orgs ||= current_person.organizations.collect { |x| x.subtree.collect(&:id)}.flatten.uniq
    @valid_org_ids ||= current_person.org_ids.keys
  end
  
  def valid_keywords
    @valid_keywords ||= SmsKeyword.where(:organization_id => valid_org_ids)
  end
 
  def authorized_leader?
    raise ApiErrors::IncorrectPermissionsError unless can?(:lead, get_organization)
  end
 
  #########################################
  #######Resource Getters##################
  #########################################
 
  def get_people
    person_ids = params[:id].split(',')
    person_ids.each_with_index do |x,i|
      person_ids[i] = User.find(oauth.identity).person.id.to_s if x == "me"
    end
    people = Person.where(:personID => person_ids)
    raise ApiErrors::NoDataReturned if people.empty?
    people
  end
  
  def get_keywords
    if params[:keyword].present?
      @keywords = SmsKeyword.find_all_by_keyword(params[:keyword])
    elsif (params[:org].present? || params[:org_id].present?)
      org_id = params[:org].present? ? params[:org].to_i : params[:org_id].to_i
      @keywords = Organization.find_by_id(org_id).try(:self_and_children_keywords) || []
    elsif params[:keyword_id].present?
      @keywords = SmsKeyword.find_all_by_id(params[:keyword_id])
    else 
      @keywords = current_organization.self_and_children_keywords
    end
  end
  
  def get_organization
    if params[:org_id].present? || params[:org].present?
      raise OrganizationNotIntegerError unless (is_int?(params[:org_id]) || is_int?(params[:org]))
      org_id_param = params[:org_id] ? params[:org_id].to_i : params[:org].to_i
      @organization = Organization.find(org_id_param)
    else
      @organization ||= current_organization(current_person)
    end
    raise NoOrganizationError unless @organization
    @organization
  end
  
  def limit_and_offset_object(object)
    #allow for start (SQL Offset) and limit on query.  use :start and :limit
    raise LimitRequiredWithStartError if (params[:start].present? && !params[:limit].present?)

    if (params[:limit].to_i > 100 || params[:limit].to_i == 0)
      params[:limit] = 100
    end
    
    object = object.offset(params[:start].to_i) if params[:start].to_i > 0
    object = object.limit(params[:limit].to_i) if params[:limit].to_i > 0
    
    object
  end
  
  def restrict_to_contact_role(people, organization)
    people = people.where("`#{OrganizationalRole.table_name}`.`organization_id` = ?", organization.id).
    where("`#{OrganizationalRole.table_name}`.`person_id` = `#{Person.table_name}`.`#{Person.primary_key}`").
    where("`#{OrganizationalRole.table_name}`.`role_id` = #{Role::CONTACT_ID}").
    where("`#{OrganizationalRole.table_name}`.`followup_status` <> 'do_not_contact'")
    
    people
  end
  
  def restrict_to_unassigned_people(people,organization)
    people = people.joins("LEFT OUTER JOIN `#{ContactAssignment.table_name}` ON `#{ContactAssignment.table_name}`.`person_id` = `#{Person.table_name}`.`#{Person.primary_key}` AND `#{ContactAssignment.table_name}`.`organization_id` = #{organization.id}").where("#{ContactAssignment.table_name}.#{ContactAssignment.primary_key}" => nil)
    
    people
  end
  
  #Pass in a Person Activerecord Query object, return ActiveRecord Query object VERSION 2
  def paginate_filter_sort_people(people, organization)
    #settings for below
    allowed_sorting_fields = ["time","status"]
    allowed_sorting_directions = ["asc", "desc"]
    allowed_filter_fields = ["gender", "status"]
    allowed_status = OrganizationalRole::FOLLOWUP_STATUSES + %w[finished not_finished]
    @sorting_fields = []
    
    people = limit_and_offset_object(people)
    
    #let's go ahead and include all of the possible tables needed for this filtering and sorting
    people = people.includes(:contact_assignments).includes(:organizational_roles)
    
    if params[:assigned_to].present? && (params[:assigned_to] == 'none' || params[:assigned_to].to_i > 0)
      if params[:assigned_to] == 'none'
        people = restrict_to_unassigned_people(people, organization)
      else
        people = people.joins(:assigned_tos).where('contact_assignments.organization_id' => organization.id, 'contact_assignments.assigned_to_id' => params[:assigned_to])
      end
    end
    
    if params[:sort].present?
      @sorting_directions = []
      @sorting_directions = params[:direction].split(',').select { |d| allowed_sorting_directions.include?(d) } if params[:direction].present?
      @sorting_fields = params[:sort].split(',').select { |s| allowed_sorting_fields.include?(s) }
      
      @sorting_fields.each_with_index do |field,index|
        case field  
        when "time"
          people = people.order("`#{OrganizationalRole.table_name}`.`created_at` #{@sorting_directions[index]}")
        when "status"
          people = people.order("`#{OrganizationalRole.table_name}`.`followup_status` #{@sorting_directions[index]}")
        end
      end
    end
    
    #if there were no sorting fields then sort by most recent org_role
    people = people.order("`#{OrganizationalRole.table_name}`.`created_at` DESC") if @sorting_fields.blank?

    
    if params[:filters].present? && params[:values].present?
      @filter_fields = params[:filters].split(',').select { |f| allowed_filter_fields.include?(f)}
      @filter_values = params[:values].split(',')
      
      @filter_fields.each_with_index do |field,index|
        case field
        when "gender"
          gender = (@filter_values[index].downcase == 'male') ? '1' : '0' if ['male', 'female'].include?(@filter_values[index].downcase)
          people = people.where("`#{Person.table_name}`.`gender` = ?", gender)
        when "status"
          status = allowed_status.include?(@filter_values[index].downcase) ? @filter_values[index].downcase : nil
          status = ["completed"] if status == "finished"
          status = ["uncontacted","attempted_contact","contacted"] if status == "not_finished"
          people = people.where('organizational_roles.followup_status' => status)
        end
      end
    end
    
    people = restrict_to_contact_role(people,organization)
    people
  end
  
  def is_int?(str)
    return !!(str =~ /^[-+]?[1-9]([0-9]*)?$/)
  end
  
  #Handle all API controller exceptions and output as JSON
  def render_json_error(exception = nil)
    finiteExceptions = ApiErrors.constants.collect { |x| "ApiErrors::#{x}"}
    oauthExceptions = [:OAuthError, :AccessDeniedError, :ExpiredTokenError, :InvalidClientError, :InvalidGrantError, :InvalidRequestError, :InvalidScopeError, :InvalidTokenError, :RedirectUriMismatchError, :UnauthorizedClientError, :UnsupportedGrantType, :UnsupportedResponseTypeError].collect { |x| "Rack::OAuth2::Server::#{x}"}
    finiteExceptions = finiteExceptions + oauthExceptions

    logger.info "#{exception.message}"
    log_api_request(exception)

    if finiteExceptions.include?(exception.class.to_s)
      output_message = exception.message
    else
      output_message = '{"error": {"message":"An unknown error has occurred.", "code":"99"}}'
      if Rails.env.production?
        Airbrake.notify(exception)
      else
        raise exception
      end
    end
    
    output = get_api_json_header()
    begin
      output[:error] = exception.to_hash
    rescue
      output[:error] = exception.to_s
    end
    
    render :json => output and return false
  end
  
  def log_api_request(exception = nil)
    if exception.nil?
      return
    end
    begin
      apiLog = {}
      apiLog[:platform] = params[:platform].to_s if params[:platform]
      apiLog[:platform_release] = params[:platform_release] if params[:platform_release]
      apiLog[:platform_product] = params[:platform_product] if params[:platform_product]
      apiLog[:app] = params[:app] if params[:app]
      apiLog[:access_token] = params[:access_token] if params[:access_token]
      apiLog[:url] = request.url
      apiLog[:action] = "#{request.path_parameters[:controller]}##{request.path_parameters[:action]}"
      apiLog[:organization_id] = @organization.nil? ? (params['org_id'] ? params['org_id'] : (params['org'] ? params['org'] : nil)) : @organization.id
      apiLog[:error] = exception.nil? ? "success" : {message: exception.message, backtrace: exception.backtrace}.to_json
      apiLog[:identity] = Rack::OAuth2::Server.get_access_token(current_access_token).identity if params[:access_token]
      apiLog[:remote_ip] = request.remote_ip

      #Airbrake.notify(exception,
        #:error_class => "Api Error",
        #:error_message => exception.message,
        #:parameters => apiLog
      #) unless exception.nil?
      ApiLog.create(apiLog)
    rescue Exception => e
      raise_or_hoptoad(e)
    end
  end
  
  def get_api_json_header
    @api_json_header = {}
    meta = {}
    meta[:request_time] = DateTime.now.utc.to_i
    meta[:request_organization] = @organization.id unless @organization.nil?
    @api_json_header[:meta] = meta
    @api_json_header
  end
end
