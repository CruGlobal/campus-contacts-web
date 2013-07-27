class Apis::V3::OrganizationalRolesController < Apis::V3::BaseController
  before_filter :ensure_filters

  def bulk
    remove_roles(filtered_people, params[:remove_roles]) if params[:remove_roles].present?
    add_roles(filtered_people, params[:add_roles]) if params[:add_roles].present?

    render json: filtered_people,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def bulk_create
    add_roles(filtered_people, params[:roles]) if params[:roles].present?

    render json: filtered_people,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def bulk_destroy
    remove_roles(filtered_people, params[:roles]) if params[:roles].present?

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

  def add_roles(people, roles)
    roles.split(',').each do |role_id|
      permission = Permission.where(id: role_id).try(:first)
      current_organization.add_permissions_to_people(filtered_people, [permission.id]) if permission.present?
      label = Label.where(id: role_id).try(:first)
      current_organization.add_labels_to_people(filtered_people, [label.id]) if label.present?
    end
  end

  def remove_roles(people, roles)
    roles.split(',').each do |role_id|
      permission = Permission.where(id: role_id).try(:first)
      current_organization.remove_permissions_from_people(filtered_people, [permission.id]) if permission.present?
      label = Label.where(id: role_id).try(:first)
      current_organization.remove_labels_from_people(filtered_people, [label.id]) if label.present?
    end
  end
end
