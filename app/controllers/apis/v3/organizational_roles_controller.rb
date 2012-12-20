class Apis::V3::OrganizationalRolesController < Apis::V3::BaseController
  before_filter :ensure_roles, only: [:bulk_add_roles, :bulk_remove_roles]
  before_filter :ensure_filters, only: [:bulk_add_roles, :bulk_remove_roles]

  def bulk_create
    current_organization.add_roles_to_people(filtered_people, params[:roles].split(','))

    render json: filtered_people,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def bulk_destroy
    current_organization.remove_roles_from_people(filtered_people, params[:roles].split(','))

    render json: filtered_people,
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

  def ensure_filters
    unless params[:filters]
      render json: {errors: ["The 'filters' parameter is required for bulk role actions."]},
                 status: :bad_request,
                 callback: params[:callback]
    end
  end

  def ensure_roles
    unless params[:roles]
      render json: {errors: ["The 'roles' parameter is required for bulk role actions."]},
                 status: :bad_request,
                 callback: params[:callback]
    end
  end

  def filtered_people
    unless @filtered_people
      @filtered_people = if params[:include_archived] == 'true'
        current_organization.people
      else
        current_organization.not_archived_people
      end

      @filtered_people = add_includes_and_order(@filtered_people)
      @filtered_people = PersonFilter.new(params[:filters]).filter(@filtered_people) if params[:filters]
    end
    @filtered_people
  end
  
end
