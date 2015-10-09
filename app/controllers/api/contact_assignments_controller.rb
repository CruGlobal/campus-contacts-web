class Api::ContactAssignmentsController < ApiController
  oauth_required scope: 'contact_assignment'
  before_action :valid_request_before, :organization_allowed?, :authorized_leader?, :get_organization, :get_api_json_header
  before_action :ensure_organization, only: [:create_2, :list_leaders_2, :list_organizations_2, :destroy_2]

  def create_1
    fail ContactAssignmentCreateParamsError unless params[:ids].present? && params[:assign_to].present? && is_int?(params[:assign_to])

    if @organization
      ids = params[:ids].split(',')
      ContactAssignment.where(person_id: ids, organization_id: @organization.id).destroy_all
      ids.each do |id|
        fail ContactAssignmentCreateParamsError unless is_int?(id)
        contact_assignment = ContactAssignment.new(person_id: id, assigned_to_id: params[:assign_to])
        contact_assignment.organization_id = current_organization.id
        contact_assignment.assigned_by_id = current_person if current_person.present?
        contact_assignment.save
      end
    else fail NoOrganizationError
    end
    render json: '[]'
  end

  def destroy_1
    fail ContactAssignmentDeleteParamsError unless params[:id].present? && (is_int?(params[:id]) || (params[:id].is_a? Array))
    ids = params[:id].split(',')
    if @organization
      ContactAssignment.where(person_id: ids, organization_id: @organization.id).destroy_all
    else fail NoOrganizationError
    end
    render json: '[]'
  end

  def create_2
    # required params: id, type = leader|organization, assign_to_id = int|none
    # recommended params: current_assign_to_id = int|none
    fail ContactAssignmentCreateParamsError unless params[:id].present? && params[:type].present? && params[:assign_to_id].present?
    fail ContactAssignmentCreateParamsError unless params[:id].to_i.to_s == params[:id]
    fail ContactAssignmentCreateParamsError unless params[:type] == 'leader' || params[:type] == 'organization'
    fail ContactAssignmentCreateParamsError unless params[:assign_to_id].to_i > 0 || params[:assign_to_id] == 'none'
    fail ContactAssignmentCreateParamsError if params[:type] == 'organization' && params[:assign_to_id] == 'none'

    id = params[:id]

    if params[:current_assign_to_id].present?
      fail ContactAssignmentCreateParamsError unless params[:current_assign_to_id].present? && (params[:current_assign_to_id].to_i > 0 || params[:current_assign_to_id] == 'none')
      if params[:type] == 'leader'
        fail ContactAssignmentStateError unless OrganizationalPermission.where(person_id: id, organization_id: @organization.id, permission_id: Permission::NO_PERMISSIONS_ID).exists?
        if params[:current_assign_to_id] == 'none'
          fail ContactAssignmentStateError if ContactAssignment.where(person_id: id, organization_id: @organization.id).exists?
        else
          fail ContactAssignmentStateError unless ContactAssignment.where(person_id: id, organization_id: @organization.id, assigned_to_id: params[:current_assign_to_id]).exists?
        end
      end
    end

    if (params[:type] == 'leader')
      if params[:assign_to_id] == 'none'
        ContactAssignment.where(person_id: id, organization_id: @organization.id).destroy_all
      else
        begin
          ContactAssignment.create!(person_id: id, organization_id: @organization.id, assigned_to_id: params[:assign_to_id])
        rescue ActiveRecord::RecordNotUnique
          ca = ContactAssignment.where(organization_id: @organization.id, person_id: id).first
          ca.update_attribute(:assigned_to_id, params[:assign_to_id]) if ca
        end
      end
    elsif (params[:type] == 'organization')
      Organization.transaction do
        begin
          from_org = Organization.find(@organization.id)
          to_org = Organization.find(params[:assign_to_id])
        rescue ActiveRecord::RecordNotFound
          raise ContactAssignmentCreateParamsError
        end
        fail ContactAssignmentStateError unless from_org != to_org
        ContactAssignment.where(person_id: id, organization_id: from_org.id).destroy_all
        from_org.move_contact(Person.find(id), from_org, to_org)
      end
    end

    output = @api_json_header
    output[:success] = true
    render json: output
  end

  def list_leaders_2
    output = @api_json_header
    output[:leaders] = @organization.leaders.collect(&:to_hash_micro_leader)
    render json: output
  end

  def list_organizations_2
    scope = Organization.subtree_of(current_organization.root_id).where('name like ?', "%#{params[:q]}%")
    @organizations = scope.order('name')
    @organizations = limit_and_offset_object(@organizations)

    output = @api_json_header
    output[:organizations] = @organizations.collect { |org| { id: org.id, name: org.name } }
    render json: output
  end

  def destroy_2
    fail ContactAssignmentDeleteParamsError unless params[:ids].present? && (is_int?(params[:ids]) || (params[:ids].is_a? Array))

    ContactAssignment.where(person_id: params[:ids].split(','), organization_id: @organization.id).destroy_all

    output = @api_json_header
    output[:success] = true
    render json: output
  end

  protected

  def ensure_organization
    fail NoOrganizationError unless @organization
  end
end
