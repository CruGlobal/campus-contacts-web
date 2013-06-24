class Apis::V4::OrganizationalPermissionsController < Apis::V3::BaseController
  before_filter :ensure_filters, only: [:bulk, :bulk_create, :bulk_destroy]

  before_filter :get_org_permission, only: [:show, :update, :destroy]

  def index
    list = add_includes_and_order(organizational_permissions)

    render json: list,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, since: params[:since]}
  end

  def show
    render json: @organizational_permission,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def create
    org_permission = OrganizationalPermission.new(params[:organizational_permission])
    org_permission.organization_id = current_organization.id
    org_permission.added_by_id = current_person.id

    if org_permission.save
      render json: org_permission,
             status: :created,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    else
      render json: {errors: org_permission.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end
  end

  def update
    if @organizational_permission.organization_id != 0
      if @organizational_permission.update_attributes(params[:organizational_permission])
        render json: @organizational_permission,
               callback: params[:callback],
               scope: {include: includes, organization: current_organization}
      else
        render json: {errors: @organizational_permission.errors.full_messages},
               status: :unprocessable_entity,
               callback: params[:callback]
      end
    end
  end

  def destroy
    if @organizational_permission.organization_id != 0
      @organizational_permission.update_attribute(:archive_date, Date.today)
      render json: @organizational_permission,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    end
  end

  def bulk
    add_permissions(filtered_people, params[:add_permission])
    remove_permissions(filtered_people, params[:remove_permission])

    render json: filtered_people,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def bulk_create
    add_permissions(filtered_people, params[:permission])

    render json: filtered_people,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def bulk_destroy
    remove_permissions(filtered_people, params[:permission])

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

  private

  def organizational_permissions
    current_organization.organizational_permissions
  end

  def get_org_permission
    @organizational_permission = add_includes_and_order(organizational_permissions)
                .find(params[:id])

  end

end
