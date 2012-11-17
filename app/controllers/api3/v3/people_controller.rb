class Api3::V3::PeopleController < Api3::V3::BaseController
  before_filter :get_person, only: [:show, :update, :destroy]

  def index
    order = params[:order] || 'last_name, first_name'

    list = people.order(order)
    list = list.includes(:email_addresses) if includes.include?('email_addresses')
    list = list.includes(:phone_numbers) if includes.include?('phone_numbers')
    list = list.limit(params[:limit]) if params[:limit]
    list = list.offset(params[:offset]) if params[:offset]
    render json: list,
           callback: params[:callback],
           scope: includes
  end

  def show
    render json: @person, callback: params[:callback], scope: includes
  end

  def create
    person = people.new(params[:person])

    if person.save

      # add roles in current org
      role_ids = params[:roles].split(',') if params[:roles]
      role_ids = [Role::CONTACT_ID] if roles.blank?
      role_ids.each do |role_id|
        current_organization.add_role_to_person(person, role_id)
      end

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

  # let the api use add additional relationships to this call
  def includes
    params[:include].to_s.split(',')
  end
end
