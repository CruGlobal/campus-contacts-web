module ApiHelper
  require 'apic.rb'
  #########################################
  #######Matt's Validation Methods#########
  #########################################
  def valid_request_with_rescue(request, in_action = nil, prms = nil, accesstoken = nil)
    begin
      x = valid_request?(request, in_action, prms, accesstoken)
    rescue Exception => e
       x = {"error" => "#{e.message}"}
    end
    x
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
    version = param.try(:version).nil? && ( (param.try(:version).nil? ? 0 : param[:version]) <= Apic::STD_VERSION) ? Apic::STD_VERSION : param[:version]
    version = ["v", version].join
    
    #Let's check to see if the fields query parameter is set first   
    if !param[:fields].nil?
      fields = param[:fields].split(',')
      raise ApiErrors::InvalidFieldError if fields.empty?
      #Let's validate the fields that they entered into the query params
      valid_fields = valid_fields?(fields, action, version)
      if valid_fields.length == fields.length
        raise ApiErrors::IncorrectScopeError unless valid_scope?(valid_fields, action, accesstoken).length == valid_fields.length 
      else raise ApiErrors::InvalidFieldError
      end
    else
      #if no fields supplied, check the scope for the action and go
      raise ApiErrors::IncorrectScopeError if valid_scope?(["all"], action, accesstoken).empty?
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
  
  def valid_scope?(fields, action, access_token = nil)
    #return the fields that are in their allowed scope of those they requested
    access_token = Rack::OAuth2::Server.get_access_token(params[:access_token]) if access_token.nil?
    allowed_scopes = access_token.scope.to_s.split(' ')
    valid_fields_by_scope = []
    fields.each do |field|
      if Apic::SCOPE_REQUIRED.has_key?(action.to_sym)
        if Apic::SCOPE_REQUIRED[action.to_sym].has_key?(field)
          Apic::SCOPE_REQUIRED[action.to_sym][field].each do |scope|
            valid_fields_by_scope.push(field) if allowed_scopes.include?(scope)
          end
        end
      end
    end
  valid_fields_by_scope
  end
  
  def get_people
    person_ids = params[:id].split(',')
    person_ids.each_with_index do |x,i|
      x[i] = User.find(oauth.identity).person.id.to_s if x == "me"
    end
    people = Person.where(:personID => person_ids)
    raise ApiErrors::NoDataReturned if people.empty?
    people
  end
  
  def get_me
    User.find(Rack::OAuth2::Server.get_access_token(params['access_token']).identity).person if params['access_token']
  end
  
  def organization_allowed?
    @valid_orgs = get_me.organizations.collect { |x| x.subtree.collect(&:id)}.flatten.uniq
    @valid_keywords = SmsKeyword.where(:organization_id => @valid_orgs)
    
    if (params[:org].present? || params[:org_id].present?)
      org_id = params[:org].present? ? params[:org].to_i : params[:org_id].to_i
      return false unless @valid_orgs.include?(org_id)
    elsif params[:keyword].present?
      @valid_key_ids = @valid_keywords.collect(&:id)
      return false unless @valid_key_ids.include?(params[:keyword])
    elsif params[:keyword_id].present?
      @valid_key_names = @valid_keywords.collect(&:keyword)
      return false unless @valid_key_names.include?(params[:keyword])
    end
  true
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
  
  def paginate_filter_sort_people(people, org)
    people = people.offset(params[:start].to_i.abs) if params[:start]
    people = people.limit(params[:limit].to_i.abs) if params[:limit] && params[:limit].to_i.abs != 0
    if params[:sort].present?
      @allowed_sorting_fields = ["time","status"]
      @sorting_fields = params[:sort].split(',').select { |s| @allowed_sorting_fields.include?(s) }
      @sorting_directions = []
      if params[:direction].present?
        @allowed_sorting_directions = ["asc", "desc"]
        @sorting_directions = params[:direction].split(',').select { |d| @allowed_sorting_directions.include?(d) }
      end
      @sorting_fields.each_with_index do |field,index|
        case field
        when "time"
          people = people.order("#{AnswerSheet.table_name}.`created_at` #{@sorting_directions[index]}") unless @sorting_directions[index].nil?
        when "status"
          status = ["uncontacted", "contacted", "attempted_contact","do_not_contact","completed"].include?(@sorting_fields[index].downcase) ? @sorting_fields[index].downcase : nil
          people = people.joins(:organization_memberships).where("`organization_memberships`.`person_id` = `ministry_person`.`personID` AND `organization_memberships`.`organization_id` = ?", org.id).order("`organization_memberships`.`followup_status` #{@sorting_directions[index]}")  
        end
      end
    end
    people = people.order("#{AnswerSheet.table_name}.`created_at` DESC") unless @sorting_fields.nil?
    
    if params[:filters].present? && params[:values].present?
      @allowed_filter_fields = ["gender", "status"]
      @filter_fields = params[:filters].split(',').select { |f| @allowed_filter_fields.include?(f)}
      @filter_values = params[:values].split(',')
      @filter_fields.each_with_index do |field,index|
        case field
        when "gender"
          gender = @filter_values[index].downcase == 'male' ? '1' : '0' if ['male','female'].include?(@filter_values[index].downcase)
          people = people.where("`ministry_person`.`gender` = ?", gender)
        when "status"
          status = ["uncontacted", "contacted", "attempted_contact","do_not_contact","completed","finished"].include?(@filter_values[index].downcase) ? @filter_values[index].downcase : nil
          status = ["do_not_contact","completed"] if status == "finished"
         # people = people.joins(:organization_memberships).where("`organization_memberships`.`followup_status` = ? AND `organization_memberships`.`person_id` = `ministry_person`.`personID` AND `organization_memberships`.`organization_id` = ?", status, org.id)
        people = people.joins(:organization_memberships).where('organization_memberships.followup_status' => status).where("`organization_memberships`.`person_id` = `ministry_person`.`personID` AND `organization_memberships`.`organization_id` = ?", org.id)
        end
      end
    end
  people
  end
  
  def get_organization
    if params[:org_id].present? || params[:org].present?
      org_id_param = params[:org_id] ? params[:org_id].to_i : params[:org].to_i
      Organization.find(org_id_param)
    else
      get_me.primary_organization
    end
  end
end
