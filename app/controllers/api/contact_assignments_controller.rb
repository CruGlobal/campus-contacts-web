class Api::ContactAssignmentsController < ApiController
  oauth_required scope: "contact_assignment"
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?, :get_organization, :get_api_json_header
  before_filter :ensure_organization, :only => [:create_2, :list_leaders_2, :list_organizations_2, :destroy_2]
  
  def create_1
    raise ContactAssignmentCreateParamsError unless ( params[:ids].present? && params[:assign_to].present? && is_int?(params[:assign_to]))
    
    if @organization
      ids = params[:ids].split(',')
      ContactAssignment.where(person_id: ids, organization_id: @organization.id).destroy_all
      ids.each do |id|
        raise ContactAssignmentCreateParamsError unless is_int?(id)
        ContactAssignment.create!(person_id: id, organization_id: @organization.id, assigned_to_id: params[:assign_to])
      end
    else raise NoOrganizationError
    end
    render json: '[]'
  end
  
  def destroy_1
    raise ContactAssignmentDeleteParamsError unless (params[:id].present? && (is_int?(params[:id]) || (params[:id].is_a? Array)))
    ids = params[:id].split(',')
    if @organization
      ContactAssignment.where(person_id: ids, organization_id: @organization.id).destroy_all
    else raise NoOrganizationError
    end
    render json: '[]'
  end
  
  def create_2
    #required params: id, type = leader|organization, assign_to_id = int|none
    #recommended params: current_assign_to_id = int|none
    raise ContactAssignmentCreateParamsError unless params[:id].present? && params[:type].present? && params[:assign_to_id].present?
    raise ContactAssignmentCreateParamsError unless params[:id].to_i.to_s == params[:id]
    raise ContactAssignmentCreateParamsError unless params[:type] == "leader" || params[:type] == "organization"
    raise ContactAssignmentCreateParamsError unless params[:assign_to_id].to_i > 0 || params[:assign_to_id] == "none"
    raise ContactAssignmentCreateParamsError unless !(params[:type] == "organization" && params[:assign_to_id] == "none")
    
    id = params[:id]
    
    if params[:current_assign_to_id].present?
      raise ContactAssignmentCreateParamsError unless params[:current_assign_to_id].present? && (params[:current_assign_to_id].to_i > 0 || params[:current_assign_to_id] == "none")
      if params[:type] == "leader"
        raise ContactAssignmentStateError unless OrganizationalRole.where(person_id: id, organization_id: @organization.id, role_id: Role::CONTACT_ID).exists?
        if params[:current_assign_to_id] == "none"
          raise ContactAssignmentStateError unless !ContactAssignment.where(person_id: id, organization_id: @organization.id).exists?
        else
          raise ContactAssignmentStateError unless ContactAssignment.where(person_id: id, organization_id: @organization.id, assigned_to_id: params[:current_assign_to_id]).exists?
        end
      end
    end
    
    if (params[:type] == "leader")
      if params[:assign_to_id] == "none"
        ContactAssignment.where(person_id: id, organization_id: @organization.id).destroy_all
      else
        begin
          ContactAssignment.create!(person_id: id, organization_id: @organization.id, assigned_to_id: params[:assign_to_id])
        rescue ActiveRecord::RecordNotUnique
          ca = ContactAssignment.find_by_organization_id_and_person_id(@organization.id, id)
          ca.update_attribute(:assigned_to_id, params[:assign_to_id]) if ca
        end
      end
    elsif (params[:type] == "organization")
      Organization.transaction do
        begin
        from_org = Organization.find(@organization.id)
        to_org = Organization.find(params[:assign_to_id])
        rescue ActiveRecord::RecordNotFound
          raise ContactAssignmentCreateParamsError
        end
        raise ContactAssignmentStateError unless from_org != to_org
        ContactAssignment.where(person_id: id, organization_id: from_org.id).destroy_all
        from_org.move_contact(Person.find(id), to_org)
      end
    end
    
    output = @api_json_header
    output[:success] = true
    render json: output
  end
  
  def list_leaders_2
    
    output = @api_json_header
    output[:leaders] = @organization.leaders.collect{|l| l.to_hash_micro_leader}
    render json: output
  end
  
  def list_organizations_2
    
    scope = Organization.subtree_of(current_organization.root_id).where("name like ?", "%#{params[:q]}%")
    @organizations = scope.order('name')
    @organizations = limit_and_offset_object(@organizations)
    
    output = @api_json_header
    output[:organizations] = @organizations.collect{|org| {id:org.id, name:org.name}};
    render json: output
  end
  
  def destroy_2
    raise ContactAssignmentDeleteParamsError unless (params[:ids].present? && (is_int?(params[:ids]) || (params[:ids].is_a? Array)))
    
    ContactAssignment.where(person_id: params[:ids].split(','), organization_id: @organization.id).destroy_all

    output = @api_json_header
    output[:success] = true
    render json: output
  end
  
  protected
    def ensure_organization
      raise NoOrganizationError unless @organization
    end
end