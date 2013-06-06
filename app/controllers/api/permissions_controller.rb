class Api::PermissionsController < ApiController
  oauth_required scope: "permissions"
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?, :get_organization
  before_filter :ensure_valid_request

  def update_1
    @person = Person.find(params[:id])
    @organization.send("add_#{params[:permission]}".to_sym, @person, current_person)
    render json: '[]'
  end

  def destroy_2
    @person = Person.find(params[:id])
    @organization.send("remove_#{params[:permission]}".to_sym, @person)
    render json: '[]'
  end


  protected

  def ensure_valid_request
    raise InvalidPermissionsParamaters unless params[:id].present? && params[:permission].present? && params[:org_id].present?
    raise PermissionsError if current_person.organizational_permissions.where(organization_id: @organization.id, permission_id: Permission::ADMIN_ID).empty?
    raise NoPermissionChangeMade unless Permission.default.collect(&:i18n).include?(params[:permission])
  end

end
