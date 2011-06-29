module ApiHelper
  require 'apic.rb'
  require 'api_errors.rb'
  include ApiErrors
  #########################################
  #######Validation Methods################
  #########################################
  
  def valid_request_before
      @valid_fields = valid_request?(request)
  end
  
  def valid_request?(request, in_action = nil, prms = nil, accesstoken = nil)
    #retrieve the API action requested so we can match the right allowed fields
    raise ApiErrors::InvalidRequest if request.try(:path_parameters).nil? && in_action.nil?
    
    #Next block of code primarily to enable testing
    if request.nil?
      request = Hashie::Mash.new()
      request[:path_parameters] = {:action => nil}
    end
    action = in_action.nil? ?  request.path_parameters[:controller].split("/")[1] : in_action
    param = prms.nil? ? params : prms
    
    #Handle versioning of API in Apic class
    version = param.try(:version).nil? && ((param.try(:version).nil? ? 0 : param[:version]) <= Apic::STD_VERSION) ? Apic::STD_VERSION : param[:version]
    version = ["v", version].join
    
    #Let's check to see if the fields query parameter is set first   
    if !param[:fields].nil?
      fields = param[:fields].split(',')
      raise ApiErrors::InvalidFieldError if fields.empty?
      #Let's validate the fields that they entered into the query params
      valid_fields = valid_fields?(fields, action, version)
      raise ApiErrors::InvalidFieldError unless valid_fields.length == fields.length
    else
      #if no fields supplied, send all
      valid_fields = Apic::API_ALLOWABLE_FIELDS[version.to_sym][action.to_sym]
    end
  valid_fields
  end
  
  def valid_fields?(fields,action,version)
    #return fields that are valid
     valid_fields = []
    if !Apic::API_ALLOWABLE_FIELDS[version.to_sym][action.to_sym].nil?
      validator = Apic::API_ALLOWABLE_FIELDS[version.to_sym][action.to_sym]
      valid_fields=[]
      fields.each do |field|
        valid_fields.push(field) if validator.include?(field)    #push all of the fields that match onto valid_fields array
      end
    end
    valid_fields
  end
 
  def organization_allowed?   
    @valid_orgs = get_me.organizations.collect { |x| x.subtree.collect(&:id)}.flatten.uniq
    @valid_keywords = SmsKeyword.where(:organization_id => @valid_orgs)
    
    if (params[:org].present? || params[:org_id].present?)
      raise ApiErrors::OrganizationNotIntegerError unless (is_int?(params[:org_id]) || is_int?(params[:org])) 
      org_id = params[:org].present? ? params[:org].to_i : params[:org_id].to_i
      raise ApiErrors::OrgNotAllowedError unless @valid_orgs.include?(org_id)
    elsif params[:keyword].present?
      @valid_key_ids = @valid_keywords.collect(&:id)
      raise ApiErrors::OrgNotAllowedError unless @valid_key_ids.include?(params[:keyword])
    elsif params[:keyword_id].present?
      raise ApiErrors::KeywordNotIntegerError unless is_int?(params[:keyword_id]) 
      @valid_key_names = @valid_keywords.collect(&:keyword)
      raise ApiErrors::OrgNotAllowedError unless @valid_key_names.include?(params[:keyword])
    end
  true
  end
 
  def authorized_leader?
    raise ApiErrors::IncorrectPermissionsError unless get_me.leader_in?(get_organization)
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
  
  def get_me
    User.find(Rack::OAuth2::Server.get_access_token(params['access_token']).identity).person if params['access_token']
  end
  
  def get_keywords
    if params[:keyword].present?
      @keywords = SmsKeyword.find_all_by_keyword(params[:keyword])
    elsif (params[:org].present? || params[:org_id].present?)
      org_id = params[:org].present? ? params[:org].to_i : params[:org_id].to_i
      @keywords = SmsKeyword.find_all_by_organization_id(org_id)
    elsif params[:keyword_id].present?
      @keywords = SmsKeyword.find_all_by_id(params[:id])
    else @keywords = SmsKeyword.find_all_by_organization_id(get_me.primary_organization.id)
    end
  end
  
  def get_organization
    if params[:org_id].present? || params[:org].present?
      raise OrganizationNotIntegerError unless (is_int?(params[:org_id]) || is_int?(params[:org]))
      org_id_param = params[:org_id] ? params[:org_id].to_i : params[:org].to_i
      @organization = Organization.find(org_id_param)
    else
      @organization = get_me.primary_organization
    end
    raise NoOrganizationError if @organization.nil?
    @organization
  end
  
  #Pass in a Person Activerecord Query object, return ActiveRecord Query object
  def paginate_filter_sort_people(people, org)
    #settings for below
    allowed_sorting_fields = ["time","status"]
    allowed_sorting_directions = ["asc", "desc"]
    allowed_filter_fields = ["gender", "status"]
    allowed_status = OrganizationMembership::FOLLOWUP_STATUSES + %w[finished not_finished]
    
    #allow for start (SQL Offset) and limit on query.  use :start and :limit
    raise LimitRequiredWithStartError if (params[:start] && !params[:limit])
    people = people.offset(params[:start]) if params[:start].to_i !=0
    people = people.limit(params[:limit]) if params[:limit].to_i != 0
    
    if params[:assigned_to].present?
      if params[:assigned_to] == 'none'
        people = unassigned_people_api(people,@organization)
      else
        people = people.joins(:assigned_tos).where('contact_assignments.organization_id' => @organization.id, 'contact_assignments.assigned_to_id' => params[:assigned_to])
      end
    end
    
    #allow for sort CSV array w/ directions CSV array.  Uses :sort and :direction
    if params[:sort].present?
      @sorting_fields = []
      @sorting_directions = []
      @sorting_directions = params[:direction].split(',').select { |d| allowed_sorting_directions.include?(d) } if params[:direction].present?
      @sorting_fields = params[:sort].split(',').select { |s| allowed_sorting_fields.include?(s) }
      @sorting_fields.each_with_index do |field,index|
        case field
        when "time"
          people = people.order("#{AnswerSheet.table_name}.`created_at` #{@sorting_directions[index]}") unless @sorting_directions[index].nil?
        when "status"
          # status = ["uncontacted", "contacted", "attempted_contact","do_not_contact","completed"].include?(@sorting_fields[index].downcase) ? @sorting_fields[index].downcase : nil
          
          if params[:assigned_to].present? && params[:assigned_to] == 'none'
            people = people.order("`organizational_roles`.`followup_status` #{@sorting_directions[index]}")  
          else 
            people = people.joins(:organizational_roles).where("`organizational_roles`.`person_id` = `ministry_person`.`personID` AND `organizational_roles`.`organization_id` = ?", org.id).order("`organizational_roles`.`followup_status` #{@sorting_directions[index]}")  
          end
        end
      end
    end
    #if there were no sorting fields then sort by most recent answer_sheet
    people = people.order("#{AnswerSheet.table_name}.`created_at` DESC") if @sorting_fields.nil?
    
    #allow for filtering by allowed_filter_fields. filters and values both CSV arrays  Uses :filters and :values
    if params[:filters].present? && params[:values].present?
      @filter_fields = params[:filters].split(',').select { |f| allowed_filter_fields.include?(f)}
      @filter_values = params[:values].split(',')
      @filter_fields.each_with_index do |field,index|
        case field
        when "gender"
          gender = @filter_values[index].downcase == 'male' ? '1' : '0' if ['male','female'].include?(@filter_values[index].downcase)
          people = people.where("`ministry_person`.`gender` = ?", gender)
        when "status"
          status = allowed_status.include?(@filter_values[index].downcase) ? @filter_values[index].downcase : nil
          status = ["do_not_contact","completed"] if status == "finished"
          status = ["uncontacted","attempted_contact","contacted"] if status == "not_finished"
          if params[:assigned_to].present? && params[:assigned_to] == 'none'
            people = people.where('organizational_roles.followup_status' => status)
          else 
            people = people.joins(:organizational_roles).where('organizational_roles.followup_status' => status).where("`organizational_roles`.`person_id` = `ministry_person`.`personID` AND `organizational_roles`.`organization_id` = ?", org.id) 
          end
        end
      end
    end
    people
  end
  
  def is_int?(str)
    return !!(str =~ /^[-+]?[1-9]([0-9]*)?$/)
  end
  
  #Handle all API controller exceptions and output as JSON
  def render_json_error(exception = nil)
    logger.info "#{exception.message}" if exception
    render :json => exception.message and return false
  end
end