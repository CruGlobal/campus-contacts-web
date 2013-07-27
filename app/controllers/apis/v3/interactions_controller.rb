class Apis::V3::InteractionsController < Apis::V3::BaseController
  before_filter :get_interaction, only: [:show, :update, :destroy]
  before_filter :get_initiator_ids, only: [:create, :update]

  def index
    render json: filtered_interactions,
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

      interaction.set_initiators(get_initiator_ids)

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

      @interaction.set_initiators(get_initiator_ids)

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

  def filtered_interactions
    unless @filtered_interactions
      order = params[:order] || 'interactions.created_at desc'
      @filtered_interactions = add_includes_and_order(interactions, {order: order})
      @filtered_interactions = InteractionFilter.new(params[:filters], current_organization).filter(@filtered_interactions) if params[:filters]
    end
    @filtered_interactions
  end

  def get_interaction
    @interaction = add_includes_and_order(interactions).find(params[:id])
  end

  def available_includes
    [:initiators]
  end

  def get_initiator_ids
    unless @initiator_ids
      @initiator_ids = params[:interaction][:initiator_ids].present? ? params[:interaction][:initiator_ids] : current_person.id
      params[:interaction].delete(:initiator_ids) if params[:interaction]

      unless @initiator_ids.is_a? Array
        @initiator_ids = @initiator_ids.to_s.split(',').collect { |x| x.strip }
      end
    end
    @initiator_ids
  end

end
