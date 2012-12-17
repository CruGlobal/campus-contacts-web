class Apis::V3::FollowupCommentsController < Apis::V3::BaseController
  before_filter :get_followup_comment, only: [:show, :update, :destroy]

  def index
    order = params[:order] || 'created_at desc'

    list = add_includes_and_order(followup_comments, order: order)

    render json: list,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, since: params[:since]}
  end

  def show
    render json: @followup_comment,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def create
    followup_comment = followup_comments.new(params[:followup_comment])
    followup_comment.organization_id = current_organization.id

    if followup_comment.save
      render json: followup_comment,
             status: :created,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    else
      render json: {errors: followup_comment.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end
  end

  def update
    if @followup_comment.update_attributes(params[:followup_comment])
      render json: @followup_comment,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    else
      render json: {errors: followup_comment.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end

  end

  def destroy
    @followup_comment.destroy

    render json: @followup_comment,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  private

  def followup_comments
    current_organization.followup_comments
  end

  def get_followup_comment
    @followup_comment = add_includes_and_order(followup_comments)
                .find(params[:id])

  end

end
