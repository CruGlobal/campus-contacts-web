class Apis::V3::QuestionsController < Apis::V3::BaseController
  before_filter :get_question, only: [:show, :update, :destroy]

  def index
    order = params[:order] || 'survey_elements.position'

    list = add_includes_and_order(questions, order: order)

    render json: list,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, since: params[:since]}
  end

  def show
    render json: @question,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def create
    if survey
      question = params[:question].delete(:kind).constantize.new(params[:question])

      if question.save
        survey.elements << question
        survey.save

        render json: question,
               status: :created,
               callback: params[:callback],
               scope: {include: includes, organization: current_organization}
      else
        render json: {errors: question.errors.full_messages},
               status: :unprocessable_entity,
               callback: params[:callback]
      end
    else
      render json: {errors: "Your api key does not have access to the survey id you send in"},
             status: :unauthorized,
             callback: params[:callback]
    end

  end

  def update
    if @question.update_attributes(params[:question])
      render json: @question,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    else
      render json: {errors: question.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end
  end

  def destroy
    @question.destroy

    render json: @question,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  private

  def questions
    survey.questions
  end

  def survey
    survey_id = params[:survey_id]
    survey_id ||= params[:question].delete(:survey_id) if params[:question]
    @survey ||= current_organization.surveys.find(survey_id)
  end

  def get_question
    @question = add_includes_and_order(questions)
                .find(params[:id])

  end

end
