class Apis::V3::OrganizationalPermissionsController < Apis::V3::BaseController
  before_filter :ensure_filters, only: [:bulk, :bulk_create, :bulk_destroy]

  def index
    order = params[:order] || 'id'
    list = add_includes_and_order(organizational_permissions, order: order)

    render json: list,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, since: params[:since]}
  end

  def bulk
    add_permissions(filtered_people, params[:add_permissions])
    remove_permissions(filtered_people, params[:remove_permissions])

    render json: filtered_people,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def bulk_create
    add_permissions(filtered_people, params[:permissions])

    render json: filtered_people,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def bulk_destroy
    remove_permissions(filtered_people, params[:permissions])

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
      render json: {errors: ["The 'filters' parameter is required for bulk permission actions."]},
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

  def add_permissions(people, permissions)
    current_organization.add_permissions_to_people(filtered_people, permissions.split(',')) if permissions
  end

  def remove_permissions(people, permissions)
    current_organization.remove_permissions_from_people(filtered_people, permissions.split(',')) if permissions
  end

  def organizational_permissions
    current_person.organizational_permissions
  end

  def get_organizational_permission
    @organizational_permission = add_includes_and_order(current_organization.people).find(params[:id])

  end


end
