class Apis::V3::PeopleController < Apis::V3::BaseController
  before_filter :get_person, only: [:show, :update, :destroy]

  def index
    order = params[:order] || 'last_name, first_name'

    list = if params[:include_archived] == 'true'
      current_organization.people
    else
      current_organization.not_archived_people
    end

    list = add_includes_and_order(list, order: order)
    list = PersonFilter.new(params[:filters]).filter(list) if params[:filters]

    render json: list,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, since: params[:since]}
  end

  def show
    render json: @person,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def create
    person = Person.find_existing_person(Person.new(params[:person]))

    if person.save

      # add roles in current org
      role_ids = params[:roles].split(',') if params[:roles]
      role_ids = [Role::CONTACT_ID] if role_ids.blank?
      role_ids.each do |role_id|
        current_organization.add_role_to_person(person, role_id)
      end

      render json: person,
             status: :created,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    else
      render json: {errors: person.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end
  end

  def update
    # add roles in current org
    if params[:roles]
      params[:roles].split(',').each do |role_id|
        current_organization.add_role_to_person(person, role_id)
      end
    end

    # remove roles in current org
    if params[:remove_roles]
      params[:remove_roles].split(',').each do |role_id|
        current_organization.remove_role_from_person(person, role_id)
      end
    end

    if params[:person]
      unless @person.update_attributes(params[:person])
        render json: {errors: @person.errors.full_messages},
               status: :unprocessable_entity,
               callback: params[:callback]
        return
      end
    end

    render json: @person,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def destroy
    current_organization.remove_person(@person)

    render json: @person,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  private

  def people
    current_organization.people
  end

  def get_person
    if params[:id] == "me"
      @person = current_user.person
    else
      @person = add_includes_and_order(people).find(params[:id])
    end
  end

  def available_includes
    [:email_addresses, :phone_numbers]
  end

end
