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
    if current_person.is_user_for_org?(current_organization)
      render_unauthorized_call
    else
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
  end

  def update
    if current_person.is_user_for_org?(current_organization)
      render_unauthorized_call
    else
      if @label.organization_id == 0
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
  end

  def destroy
    if current_person.is_user_for_org?(current_organization)
      render_unauthorized_call
    else
      if @label.organization_id == 0
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
  end

  private

  def labels
    current_organization.labels
  end

  def get_label
    @label = add_includes_and_order(labels).find(params[:id])

  end

end
