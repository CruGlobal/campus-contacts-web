class Apis::V4::InteractionTypesController < Apis::V3::BaseController
  before_filter :get_interaction_type, only: [:show, :update, :destroy]

  def index
    order = params[:order] || 'created_at desc'

    list = add_includes_and_order(interaction_types, order: order)

    render json: list.collect(&:to_hash),
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, since: params[:since]}
  end

  def show
    render json: @interaction_type.to_hash,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def create
    interaction_type = InteractionType.new(params[:interaction_type])
    interaction_type.organization_id = current_organization.id

    if interaction_type.save
      render json: interaction_type.to_hash,
             status: :created,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    else
      render json: {errors: interaction_type.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end
  end

  def update
    if @interaction_type.update_attributes(params[:interaction_type])
      render json: @interaction_type.to_hash,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    else
      render json: {errors: interaction_type.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end

  end

  def destroy
    @interaction_type.destroy if @interaction_type.organization_id == current_organization.id
    render json: @interaction_type.to_hash,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  private

  def interaction_types
    current_organization.interaction_types
  end

  def get_interaction_type
    @interaction_type = add_includes_and_order(interaction_types).find(params[:id])
  end

end
