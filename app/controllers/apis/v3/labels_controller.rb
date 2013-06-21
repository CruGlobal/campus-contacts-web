class Apis::V3::LabelsController < Apis::V3::BaseController
  before_filter :get_label, only: [:show, :update, :destroy]

  def index
    order = params[:order] || 'name'

    list = add_includes_and_order(labels, order: order)

    render json: list,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, since: params[:since]}
  end

  def show
    render json: @label,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def create
    label = labels.new(params[:label])
    label.organization_id = current_organization.id

    if label.save
      render json: label,
             status: :created,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    else
      render json: {errors: label.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end
  end

  def update
    if @label.organization_id != 0
      if @label.update_attributes(params[:label])
        render json: @label,
               callback: params[:callback],
               scope: {include: includes, organization: current_organization}
      else
        render json: {errors: label.errors.full_messages},
               status: :unprocessable_entity,
               callback: params[:callback]
      end
    end
  end

  def destroy
    if @label.organization_id != 0
      @label.destroy

      render json: @label,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    end
  end

  private

  def labels
    current_organization.labels
  end

  def get_label
    @label = add_includes_and_order(labels)
                .find(params[:id])

  end

end
