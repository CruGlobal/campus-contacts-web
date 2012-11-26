class Apis::V3::SurveysController < Apis::V3::BaseController
  before_filter :get_survey, only: [:show, :update, :destroy]

  def index
    order = params[:order] || 'title'

    list = add_includes_and_filters(surveys, order: order)

    render json: list,
           callback: params[:callback],
           scope: includes
  end

  def show
    render json: @survey,
           callback: params[:callback],
           scope: includes
  end

  def create
    survey = surveys.new(params[:survey])

    if survey.save
      render json: survey,
             status: :created,
             callback: params[:callback],
             scope: includes
    else
      render json: {errors: survey.errors.full_messages},
             status: :bad_request,
             callback: params[:callback]
    end
  end

  def update
    if @survey.update_attributes(params[:survey])
      render json: @survey,
             callback: params[:callback],
             scope: includes
    else
      render json: {errors: survey.errors.full_messages},
             status: :bad_request,
             callback: params[:callback]
    end

  end

  def destroy
    @survey.destroy

    render json: @survey,
           callback: params[:callback],
           scope: includes
  end

  private

  def surveys
    current_organization.surveys
  end

  def get_survey
    @survey = add_includes_and_filters(surveys)
                .find(params[:id])

  end

  def available_includes
    [:keyword, :questions]
  end

end
