class Api::ContactAssignmentsController < ApiController
  oauth_required scope: "contact_assignment"
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?, :get_organization
  
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
end