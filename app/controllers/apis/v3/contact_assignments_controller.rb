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
  
  def bulk_update
    error_messages = []
    begin
      ActiveRecord::Base.transaction do
          assignments = params[:contact_assignments].collect do |k, assignment|
            contact_assignment = assignment[:id] ? contact_assignments.find(assignment[:id]) : contact_assignments.new  
            contact_assignment.attributes = assignment
            unless contact_assignment.save
              error_messages += contact_assignment.errors.full_messages
            end
          contact_assignment
        end
        
        raise 'invalid' if error_messages.present?
        
        render json: assignments,
               callback: params[:callback],
               scope: {include: includes, organization: current_organization}
      end
    rescue => err
      error_messages = [err.to_s] if error_messages.empty?
      render json: {errors: error_messages},
             status: :unprocessable_entity,
             callback: params[:callback]
    end
  end
  
  def destroy
    @contact_assignment.destroy

    render json: @contact_assignment,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, deleted: true}
  end
  
  def bulk_destroy
    @contact_assignments = add_includes_and_order(contact_assignments).find(params[:ids].split(','))
    @contact_assignments.each do |assignment|
      assignment.destroy
    end
    render json: @contact_assignments,
           callback: params[:callback],
           scope: {include: includes, organization: current_organization, deleted: true}
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
