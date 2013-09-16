class Apis::V3::OrganizationalPermissionsController < Apis::V3::BaseController
  before_filter :ensure_filters, only: [:bulk, :bulk_create, :bulk_destroy]
  before_filter :get_organizational_permission, only: [:show, :update, :destroy, :archive]

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

    if org_permission.permission_id == Permission::ADMIN_ID && current_person.is_user_for_org?(current_organization)
      render_unauthorized_call
    elsif org_permission.save
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
    if params[:organizational_permission][:permission_id] == Permission::ADMIN_ID && current_person.is_user_for_org?(current_organization)
      render_unauthorized_call
    elsif @organizational_permission.permission_id == Permission::ADMIN_ID && current_person.is_user_for_org?(current_organization)
      render_unauthorized_call
    elsif @organizational_permission.update_attributes(params[:organizational_permission])
      render json: @organizational_permission,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    else
      render json: {errors: @organizational_permission.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end
  end

  def destroy
    if @organizational_permission.permission_id == Permission::ADMIN_ID && current_person.is_user_for_org?(current_organization)
      render_unauthorized_call
    else
      @organizational_permission.delete
      render json: @organizational_permission,
            callback: params[:callback],
            scope: {include: includes, organization: current_organization}
    end
  end

  def archive
    if @organizational_permission.permission_id == Permission::ADMIN_ID && current_person.is_user_for_org?(current_organization)
      render_unauthorized_call
    else
      @organizational_permission.archive
      render json: @organizational_permission,
            callback: params[:callback],
            scope: {include: includes, organization: current_organization}
    end
  end

  def bulk
    if params[:add_permission].present? && params[:add_permission].split(',').include?(Permission::ADMIN_ID.to_s) && current_person.is_user_for_org?(current_organization)
      render_unauthorized_call("You do not have permission to create the Admin permission level in organization=#{current_organization.id}.")
    elsif params[:remove_permission].present? && params[:remove_permission].split(',').include?(Permission::ADMIN_ID.to_s) && current_person.is_user_for_org?(current_organization)
      render_unauthorized_call("You do not have permission to destroy the Admin permission level in organization=#{current_organization.id}.")
    else
      add_permissions(filtered_people, params[:add_permission])
      remove_permissions(filtered_people, params[:remove_permission])
      set_status(filtered_people, params[:followup_status]) if params[:followup_status]

      render json: filtered_people,
            callback: params[:callback],
              scope: {include: includes, organization: current_organization},
              root: 'people'
    end
  end

  def bulk_create
    if params[:permission].present? && params[:permission].split(',').include?(Permission::ADMIN_ID.to_s) && current_person.is_user_for_org?(current_organization)
      render_unauthorized_call("You do not have permission to create the Admin permission level in organization=#{current_organization.id}.")
    else
      add_permissions(filtered_people, params[:permission])
      render json: filtered_people,
              callback: params[:callback],
              scope: {include: includes, organization: current_organization},
              root: 'people'
    end
  end

  def bulk_destroy
    if params[:permission].present? && params[:permission].split(',').include?(Permission::ADMIN_ID.to_s) && current_person.is_user_for_org?(current_organization)
      render_unauthorized_call("You do not have permission to destroy the Admin permission level in organization=#{current_organization.id}.")
    else
      remove_permissions(filtered_people, params[:permission])
      render json: filtered_people,
              callback: params[:callback],
              scope: {include: includes, organization: current_organization},
              root: 'people'
    end
  end

  def bulk_archive
    if params[:permission].present? && params[:permission].split(',').include?(Permission::ADMIN_ID.to_s) && current_person.is_user_for_org?(current_organization)
      render_unauthorized_call
    else
      archive_permissions(filtered_people, params[:permission])
      render json: filtered_people,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization},
             root: 'people'
    end
  end


  private

  def people
    current_organization.people
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
      @filtered_people = PersonOrder.new(params[:order]).order(@filtered_people) if params[:order]
      @filtered_people = PersonFilter.new(params[:filters]).filter(@filtered_people) if params[:filters]
    end
    @filtered_people
  end

  def add_permissions(people, permissions)
    current_organization.add_permissions_to_people(people, permissions.split(',')) if permissions
  end

  def remove_permissions(people, permissions)
    current_organization.remove_permissions_from_people(people, permissions.split(',')) if permissions
  end

  def archive_permissions(people, permissions)
    current_organization.archive_permissions_from_people(people, permissions.split(',')) if permissions
  end

  def set_status(people, status)
    people.each do |person|
      current_organization.set_followup_status(person, status)
    end
  end

  def organizational_permissions
    current_organization.organizational_permissions
  end

  def get_organizational_permission
    @organizational_permission = add_includes_and_order(organizational_permissions).find(params[:id])
  end
end
