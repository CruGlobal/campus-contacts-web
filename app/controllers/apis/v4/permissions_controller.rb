class Apis::V4::PermissionsController < Apis::V3::BaseController
  before_filter :get_permission, only: [:show]

  def index
    order = params[:order] || 'name'

    list = add_includes_and_order(permissions, order: order)

    render json: list,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, since: params[:since]}
  end

  def show
    render json: @permission,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  private

  def permissions
    current_organization.permissions
  end

  def get_permission
    @permission = add_includes_and_order(permissions)
                .find(params[:id])

  end

  def available_includes
    [:email_addresses, :phone_numbers]
  end

end
