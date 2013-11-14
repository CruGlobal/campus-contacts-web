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
    if current_person.is_user_for_org?(current_organization)
      render_unauthorized_call
    else
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
  end

  def update
    if current_person.is_user_for_org?(current_organization)
      render_unauthorized_call
    elsif params[:id].to_i != current_organization.id
      render_unauthorized_call
    else
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
  end

  def destroy
    if current_person.is_user_for_org?(current_organization)
      render_unauthorized_call
    elsif !current_organization.self_and_descendant_ids.include?(params[:id].to_i)
      render_unauthorized_call("You do not have permission to delete organization #{params[:id]}. You must but an Admin of this organization or one of its parent organization.")
    elsif current_organization.id == params[:id].to_i
      render_unauthorized_call("You can't delete the organization associated with the API secret you are using")
    else
      @organization.destroy
      render json: @organization,
             callback: params[:callback],
             scope: includes
    end
  end

  private

  def organizations
    current_organization.subtree
  end

  def get_organization
    @organization = add_includes_and_order(organizations)
                      .find(params[:id].to_i)

  end

  def available_includes
    [:contacts, :admins, :people, :surveys, :groups, :keywords, :labels, :users]
  end

end
