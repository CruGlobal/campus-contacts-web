class Apis::V3::InteractionsController < Apis::V3::BaseController
  before_filter :get_interaction, only: [:show, :update, :destroy]

  def index
    order = params[:order] || 'created_at desc'

    list = add_includes_and_order(interactions, order: order)

    render json: list,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, since: params[:since]}
  end

  def show
    render json: @interaction,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def create
    interaction = Interaction.new(params[:interaction])
    interaction.organization_id = current_organization.id
    interaction.created_by_id = current_person.id

    if interaction.save
      render json: interaction,
             status: :created,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    else
      render json: {errors: interaction.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end
  end

  def update
    params[:interaction].delete(:created_by_id) if params[:interaction].present?
    params[:interaction][:updated_by_id] = current_person.id if params[:interaction].present?
    if @interaction.update_attributes(params[:interaction])
      render json: @interaction,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    else
      render json: {errors: interaction.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end
  end

  def destroy
    @interaction.destroy
    render json: @interaction,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  private

  def interactions
    current_organization.interactions
  end

  def get_interaction
    @interaction = add_includes_and_order(interactions).find(params[:id])
  end

  def available_includes
    [:initiators]
  end

end
