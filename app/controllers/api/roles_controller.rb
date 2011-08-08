class Api::RolesController < ApiController
  oauth_required scope: "roles"
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?, :get_organization
  
  def update_1
    raise InvalidRolesParamaters unless params[:id].present? && params[:role].present? && params[:org_id].present?
    raise RolesPermissionsError if current_person.organizational_roles.where(organization_id: @organization.id, role_id: Role::ADMIN_ID).empty?
    role = Role.where(i18n: params[:role]).first.id
    
    @roles = OrganizationalRole.where(person_id: params[:id], organization_id: @organization.id)
    
    mh_roles = [Role::ADMIN_ID.to_s, Role::CONTACT_ID.to_s, Role::LEADER_ID.to_s]
    @role_to_update = @roles.collect {|x| x if mh_roles.include?(x.role_id.to_s)}.try(:first)
    
    raise NoRoleChangeMade unless @role_to_update
    
    update_hash = {}
    if role == Role::CONTACT_ID
      update_hash[:followup_status] = OrganizationMembership::FOLLOWUP_STATUSES.first
    end
    update_hash[:role_id] = role.to_s
    @role_to_update.update_attributes(update_hash)

    render json: '[]'
  end
end
