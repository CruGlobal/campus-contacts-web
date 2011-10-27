class Api::OrganizationsController < ApiController
  oauth_required scope: "organization_info"
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?, :get_organization, :get_api_json_header
  
  def show_1
    json_output = []
    
    if (params[:id].present? && params[:id].to_s.downcase != "all")
      org_roles = OrganizationalRole.includes(:organization).where(organization_id: params[:id].split(','), person_id: current_person.id, role_id: Role.leader_ids)
    else
      org_roles = OrganizationalRole.includes(:organization).where(person_id: current_person.id, role_id: Role.leader_ids)
    end
    
    # Get all of the organizations from org_roles
    orgs = Organization.includes(:leaders, {:keywords=>{:question_sheets=>{:pages=>:questions}}}).find(org_roles.collect{|x| x.organization_id})
    
    orgs.each do |org|
      # Initial hash with id and name
      json = {id:org.id, name:org.name}
      
      # Ancestry
      org.ancestry.nil? ? json[:ancestry] = [] : json[:ancestry] = org.ancestry.split('/')
      
      # Leaders
      json[:leaders] = org.leaders.collect{|l| l.to_hash_mini_leader}
      
      # Keywords and Questions
      json[:keywords] = []
      org.keywords.order("keyword").each do |keyword|
          keyword_json = {keyword:keyword.keyword, questions: [], state: keyword.state}
          keyword.questions.each do |q|
             build_question_json(keyword_json, q, true)
          end
          keyword.archived_questions.each do |q|       
            build_question_json(keyword_json, q, false)
          end
          json[:keywords]<<keyword_json
      end
      
      json_output<<json
    end
    
    output = @api_json_header
    output[:organizations] = json_output
    
    render json: output
  end
  
  def build_question_json ( keyword_json, q, active)
    question_json = {id: q.id, label:q.label, style:q.style, required:q.required};
    question_json[:object_name] = q.object_name unless q.object_name.nil?
    question_json[:attribute_name] = q.attribute_name unless q.attribute_name.nil?
    question_json[:required] = 0 unless !q.required.nil?
    question_json[:choices] = q.content.split(/[\r\n]/).compact.reject { |s| s.empty? } unless (q.content.nil? || q.kind != "ChoiceField")
    question_json[:active] = active unless active.nil?
    keyword_json[:questions] << question_json
  end
  
  def index_1
    show_1
  end
end