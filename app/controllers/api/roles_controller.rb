class Api::RolesController < ApiController
  oauth_required scope: "roles"
  before_filter :translate_role
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?, :get_organization
  before_filter :ensure_valid_request

  def update_1
    @person = Person.find(params[:id])
    @organization.send("add_#{params[:role]}".to_sym, @person)
    render json: '[]'
  end

  def destroy_2
    @person = Person.find(params[:id])
    @organization.send("remove_#{params[:role]}".to_sym, @person)
    render json: '[]'
  end

  protected

  def translate_role
    case params[:role]
      when 'leader'
        params[:role] = 'user'
      when 'contact'
        params[:role] = 'no_permissions'
    end
  end

  def ensure_valid_request
    raise InvalidRolesParamaters unless params[:id].present? && params[:role].present? && params[:org_id].present?
    raise NoRoleChangeMade unless Permission.default.collect(&:i18n).include?(params[:role])
  end

end
