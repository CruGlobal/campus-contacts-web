class Apis::V3::OrganizationalRolesController < Apis::V3::BaseController
  before_filter :ensure_bulk_parameters, only: [:bulk]
  before_filter :ensure_filters, only: [:bulk]
  
  def bulk
    current_organization.add_roles_to_people(filtered_people, params[:add_roles].split(',')) if params[:add_roles]
    current_organization.remove_roles_from_people(filtered_people, params[:remove_roles].split(',')) if params[:remove_roles]
    
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
  
  def ensure_bulk_parameters
    unless params[:add_roles] || params[:remove_roles]
      render json: {errors: ["The 'add_roles' and/or 'remove_roles' parameters are required for bulk role actions."]},
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
