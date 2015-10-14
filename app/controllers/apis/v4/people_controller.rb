class Apis::V4::PeopleController < Apis::V4::BaseController
  before_action :get_person, only: [:show, :update, :destroy, :archive]

  def index
    render json: people,
           callback: params[:callback],
           scope: { include: includes, organization: current_organization, user: current_user }
  end

  def show
    render json: @person,
           callback: params[:callback],
           scope: { include: includes, organization: current_organization, user: current_user }
    # serializer: V4::PersonSerializer
  end

  def update
    if @person.update_attributes(person_params)
      render json: @person,
             callback: params[:callback],
             scope: { include: includes, organization: current_organization, user: current_user }
    else
      render json: { errors: @person.errors.full_messages },
             status: :unprocessable_entity,
             callback: params[:callback]
    end
  end

  private

  def person_params
    @person_params ||= params.require(:person).permit(::V4::Person::PERMITTED_ATTRIBUTES)
  end

  def people
    current_organization.people
  end

  def get_person
    if params[:id] == 'me'
      @person = current_user.person
    else
      @person = people.find(params[:id])
    end
  end

  def available_includes
    [:email_addresses, :phone_numbers, :addresses]
  end
end
