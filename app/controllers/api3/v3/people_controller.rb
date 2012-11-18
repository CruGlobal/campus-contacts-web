class Api3::V3::PeopleController < Api3::V3::BaseController
  before_filter :get_person, only: [:show, :update, :destroy]

  def index
    order = params[:order] || 'last_name, first_name'

    list = add_includes_and_filters(people, order: order)

    render standard_response(list)
  end

  def show
    render standard_response(@person)
  end

  def create
    person = people.new(params[:person])

    if person.save

      # add roles in current org
      role_ids = params[:roles].split(',') if params[:roles]
      role_ids = [Role::CONTACT_ID] if role_ids.blank?
      role_ids.each do |role_id|
        current_organization.add_role_to_person(person, role_id)
      end

      render standard_response(person, :created)
    else
      render error_response(person.errors.full_messages)
    end
  end

  def update
    if @person.update_attributes(params[:person])
      render standard_response(@person)
    else
      render error_response(person.errors.full_messages)
    end

  end

  def destroy
    current_organization.remove_person(@person)

    render standard_response(@person)
  end

  private

  def people
    current_organization.people
  end

  def get_person
    @person = add_includes_and_filters(people)
                .find(params[:id])

  end

  def available_includes
    [:email_addresses, :phone_numbers]
  end

end
