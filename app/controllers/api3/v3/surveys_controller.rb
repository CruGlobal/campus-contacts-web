class Api3::V3::SurveysController < Api3::V3::BaseController
  before_filter :get_survey, only: [:show, :update, :destroy]

  def index
    order = params[:order] || 'title'

    list = add_includes_and_filters(surveys, order: order)

    render standard_response(list)
  end

  def show
    render standard_response(@survey)
  end

  def create
    survey = surveys.new(params[:survey])

    if survey.save
      render standard_response(survey, :created)
    else
      render error_response(survey.errors.full_messages)
    end
  end

  def update
    if @survey.update_attributes(params[:survey])
      render standard_response(@survey)
    else
      render error_response(survey.errors.full_messages)
    end

  end

  def destroy
    @survey.destroy

    render standard_response(@survey)
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
