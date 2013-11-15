class Apis::V3::SurveysController < Apis::V3::BaseController
  before_filter :get_survey, only: [:show, :update, :destroy]

  def index
    order = params[:order] || 'title'
    list = add_includes_and_order(surveys, order: order)
    render json: list,
           callback: params[:callback],
           scope: {include: includes, since: params[:since]}
  end

  def show
    render json: @survey,
           callback: params[:callback],
           scope: includes
  end

  def create
    if current_person.is_user_for_org?(current_organization)
      render_unauthorized_call
    else
      survey = surveys.new(params[:survey])
      if survey.save
        render json: survey,
               status: :created,
               callback: params[:callback],
               scope: includes
      else
        render json: {errors: survey.errors.full_messages},
               status: :unprocessable_entity,
               callback: params[:callback]
      end
    end
  end

  def update
    if current_person.is_user_for_org?(current_organization)
      render_unauthorized_call
    else
      if @survey.update_attributes(params[:survey])
        render json: @survey,
               callback: params[:callback],
               scope: includes
      else
        render json: {errors: survey.errors.full_messages},
               status: :unprocessable_entity,
               callback: params[:callback]
      end
    end
  end

  def destroy
    if current_person.is_user_for_org?(current_organization)
      render_unauthorized_call
    else
      @survey.destroy
      render json: @survey,
             callback: params[:callback],
             scope: includes
    end
  end

  private

  def surveys
    current_organization.surveys
  end

  def get_survey
    @survey = add_includes_and_order(surveys).find(params[:id])
  end

  def available_includes
    [:keyword, :questions]
  end

end
