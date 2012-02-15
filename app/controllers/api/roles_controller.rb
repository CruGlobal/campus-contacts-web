class Api::RolesController < ApiController
  oauth_required scope: "roles"
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?, :get_organization
  
  def update_1
    raise InvalidRolesParamaters unless params[:id].present? && params[:role].present? && params[:org_id].present?
    raise RolesPermissionsError if current_person.organizational_roles.where(organization_id: @organization.id, role_id: Role::ADMIN_ID).empty?
    raise NoRoleChangeMade unless Role.default.collect(&:i18n).include?(params[:role])
    @person = Person.find(params[:id])
    @organization.send("add_#{params[:role]}".to_sym, @person, current_person)
    render json: '[]'
  end
end
