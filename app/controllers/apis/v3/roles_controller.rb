class Apis::V3::RolesController < Apis::V3::BaseController
  before_filter :get_role, only: [:show, :update, :destroy]

  def index
    order = params[:order] || 'name'

    list = add_includes_and_filters(roles, order: order)

    render json: list,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def show
    render json: @role,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def create
    role = roles.new(params[:role])
    role.organization_id = current_organization.id

    if role.save
      render json: role,
             status: :created,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    else
      render json: {errors: role.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end
  end

  def update
    if @role.update_attributes(params[:role])
      render json: @role,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    else
      render json: {errors: role.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end

  end

  def destroy
    @role.destroy

    render json: @role,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  private

  def roles
    current_organization.roles
  end

  def get_role
    @role = add_includes_and_filters(roles)
                .find(params[:id])

  end

  def available_includes
    [:email_addresses, :phone_numbers]
  end

end
