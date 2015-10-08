class Api::RolesController < ApiController
  oauth_required scope: 'roles'
  before_action :translate_role
  before_action :valid_request_before, :organization_allowed?, :authorized_leader?, :get_organization
  before_action :ensure_valid_request

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
    fail InvalidRolesParamaters unless params[:id].present? && params[:role].present? && params[:org_id].present?
    fail NoRoleChangeMade unless Permission.default.collect(&:i18n).include?(params[:role])
  end
end
