class Api::RolesController < ApiController
  oauth_required scope: "roles"
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?, :get_organization
  before_filter :ensure_valid_request

  def update_1
    @person = Person.find(params[:id])
    @organization.send("add_#{params[:role]}".to_sym, @person, current_person)
    render json: '[]'
  end

  def destroy_2
    @person = Person.find(params[:id])
    @organization.send("remove_#{params[:role]}".to_sym, @person)
    render json: '[]'
  end


  protected

  def ensure_valid_request
    raise InvalidRolesParamaters unless params[:id].present? && params[:role].present? && params[:org_id].present?
    raise RolesPermissionsError if current_person.organizational_roles.where(organization_id: @organization.id, role_id: Role::ADMIN_ID).empty?
    raise NoRoleChangeMade unless Role.default.collect(&:i18n).include?(params[:role])
  end

end
