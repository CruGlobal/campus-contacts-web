class ContactAssignmentsController < ApplicationController
  def create
    @organization = params[:org_id].present? ? Organization.find(params[:org_id]) : current_organization
    # @keyword = SmsKeyword.find(params[:keyword])
    ContactAssignment.where(person_id: params[:ids], organization_id: @organization.id).destroy_all
    if params[:assign_to].present?
      @assign_to = Person.find(params[:assign_to])
      params[:ids].each do |id|
        ContactAssignment.create!(person_id: id, organization_id: @organization.id, assigned_to_id: @assign_to.id)
      end
    else
      
    end
    render nothing: true
  end
end
