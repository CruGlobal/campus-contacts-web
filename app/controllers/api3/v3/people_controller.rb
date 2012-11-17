class Api3::V3::PeopleController < Api3::V3::BaseController
  before_filter :get_person, only: [:show, :update, :destroy]

  def index
    order = params[:order] || 'last_name, first_name'
    render json: people.order(order)
                        .includes([:email_addresses, :phone_numbers]),
           callback: params[:callback]
  end

  def show
    render json: @person, callback: params[:callback]
  end

  def create
    person = people.new(params[:person])
    if person.save
      render json: person,
             status: :created,
             callback: params[:callback]
    else
      render json: {errors: person.errors.full_messages},
             status: :bad_request,
             callback: params[:callback]
    end
  end

  def update
    if @person.update_attributes(params[:person])
      render json: @person,
             callback: params[:callback]
    else
      render json: {errors: @person.errors.full_messages},
             status: :bad_request,
             callback: params[:callback]
    end

  end

  def destroy
    current_organization.remove_person(@person)
  end

  private

  def people
    current_organization.people
  end

  def get_person
    @person = people.find(params[:id])
  end
end
