class Apis::V3::AnswersController < Apis::V3::BaseController
  before_filter :get_answer, only: [:show, :update, :destroy]

  def index
    order = params[:order] || 'created_at desc'

    list = add_includes_and_order(answers.where(question_id: params[:question_ids]), order: order)

    render json: list,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, since: params[:since]}
  end

  private

  def answers
    current_organization.answers
  end

  def get_answer
    @answer = add_includes_and_order(answers)
                .find(params[:id])

  end

end
