class Apis::V3::ContactAssignmentsController < Apis::V3::BaseController
  before_filter :get_contact_assignment, only: [:show, :update, :destroy]

  def index
    list = add_includes_and_order(contact_assignments)
    list = ContactAssignmentFilter.new(params[:filters]).filter(list) if params[:filters]

    render json: list,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, since: params[:since]}
  end

  def show
    render json: @contact_assignment,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  def create
    contact_assignment = contact_assignments.new(params[:contact_assignment])
    contact_assignment.organization_id = current_organization.id

    if contact_assignment.save
      render json: contact_assignment,
             status: :created,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    else
      render json: {errors: contact_assignment.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end
  end

  def update
    if @contact_assignment.update_attributes(params[:contact_assignment])
      render json: @contact_assignment,
             callback: params[:callback],
             scope: {include: includes, organization: current_organization}
    else
      render json: {errors: contact_assignment.errors.full_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end

  end

  def destroy
    @contact_assignment.destroy

    render json: @contact_assignment,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization}
  end

  private

  def contact_assignments
    current_organization.contact_assignments
  end

  def get_contact_assignment
    @contact_assignment = add_includes_and_order(contact_assignments)
                .find(params[:id])

  end

  def available_includes
    [:assigned_to, :person]
  end

end
