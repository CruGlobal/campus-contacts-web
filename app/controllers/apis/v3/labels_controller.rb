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
    if @label.nil?
      render json: {errors: ["Label not found"]},
             status: :unprocessable_entity,
             callback: params[:callback]
    else
      render json: @label,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    end
  end

  def create
    label = Label.new(params[:label])
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
    if @label.nil?
      render json: {errors: ["You can't update labels from another organization"]},
             status: :unprocessable_entity,
             callback: params[:callback]
    elsif @label.organization_id == 0
      render json: {errors: ["You can't update the default labels"]},
             status: :unprocessable_entity,
             callback: params[:callback]
    else
      if @label.update_attributes(params[:label])
        render json: @label,
               callback: params[:callback],
               scope: {include: includes, organization: current_organization}
      else
        render json: {errors: @label.errors.full_messages},
               status: :unprocessable_entity,
               callback: params[:callback]
      end
    end
  end

  def destroy
    if @label.nil?
      render json: {errors: ["Label not found"]},
             status: :unprocessable_entity,
             callback: params[:callback]
    elsif @label.organization_id == 0
      render json: {errors: ["You can't delete the default labels"]},
             status: :unprocessable_entity,
             callback: params[:callback]
    else
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
    @label = add_includes_and_order(labels).where(id: params[:id]).try(:first)

  end

end
