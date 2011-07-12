class Api::RolesController < ApiController
  oauth_required scope: "roles"
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?, :get_organization
  
  def update_1
    raise InvalidRolesParamaters unless params[:id].present? && is_int?(params[:id]) && params[:role].present? && params[:org_id].present?
    raise RolesPermissionsError if get_me.organizational_roles.where(organization_id: @organization.id, role_id: 1).empty?
    case params[:role]
    when "leader"
      role = Role.leader.id
    when "admin"
      role = Role.admin.id
    when "contact"
      role = Role.contact.id
    end
    
    @roles = OrganizationalRole.where(person_id: params[:id], organization_id: @organization.id)
    mh_roles = [Role.admin.id.to_s, Role.contact.id.to_s, Role.leader.id.to_s]
    @role_to_update = @roles.collect {|x| x if mh_roles.include?(x.role_id.to_s)}.try(:first)
    
    unless @role_to_update.nil?
      update_hash = {}
      if role == Role.contact.id
        update_hash[:followup_status] = OrganizationMembership::FOLLOWUP_STATUSES.first
      end
      update_hash[:role_id] = role.to_s
      @role_to_update.update_attributes(update_hash)
    else 
      raise NoRoleChangeMade
    end
    raise @role_to_update.inspect
    render json: '[]'
  end
end
