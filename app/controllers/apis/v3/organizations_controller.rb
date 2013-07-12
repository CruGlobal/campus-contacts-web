class Apis::V3::OrganizationsController < Apis::V3::BaseController
  before_filter :get_organization, only: [:show, :update, :destroy]

  def index
    order = params[:order] || 'name'

    list = add_includes_and_order(organizations, order: order)

    render json: list,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, since: params[:since]}
  end

  def show
    render json: @organization,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def create
    organization = organizations.new(params[:organization])

    if organization.save
      render json: organization,
             status: :created,
             callback: params[:callback],
             scope: includes
    else
      render json: {errors: organization.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end
  end

  def update
    if @organization.update_attributes(params[:organization])
      render json: @organization,
             callback: params[:callback],
             scope: includes
    else
      render json: {errors: organization.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end

  end

  def destroy
    if @current_organization == @organization
      render json: {errors: ["You can't delete the organization associated with the API secret you are using"]},
             status: :bad_request,
             callback: params[:callback]
    else
      @organization.destroy

      render json: @organization,
             callback: params[:callback],
             scope: includes
    end

  end

  private

  def organizations
    @current_organization.subtree
  end

  def get_organization
    @organization = add_includes_and_order(organizations)
                      .find(params[:id])

  end

  def available_includes
    [:contacts, :admins, :people, :surveys,
     :groups, :keywords, :labels, :users]
  end

end
