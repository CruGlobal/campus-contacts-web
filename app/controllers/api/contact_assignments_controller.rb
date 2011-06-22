class Api::ContactAssignmentsController < ApiController
  require 'api_helper'
  include ApiHelper
  oauth_required :scope => "contact_assignment"
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?, :get_organization
  skip_before_filter :verify_authenticity_token, :authenticate_user!
  rescue_from Exception, :with => :render_json_error
  
  def create_1
    raise ContactAssignmentCreateParamsError unless ( params[:ids].present? && params[:assign_to].present? && is_int?(params[:assign_to]))
    
    if @organization
      ids = params[:ids].split(',')
      ContactAssignment.where(:person_id => ids, :organization_id => @organization.id).destroy_all
      #@assign_to = Person.find(params[:assign_to])
      ids.each do |id|
        raise ContactAssignmentCreateParamsError unless is_int?(id)
        ContactAssignment.create!(:person_id => id, :organization_id => @organization.id, :assigned_to_id => params[:assign_to])
      end
    else raise NoOrganizationError
    end
    render :json => '[]'
  end
  
  def destroy_1
    raise ContactAssignmentDeleteParamsError unless (params[:id].present? && is_int?(params[:id]))
    ids = params[:id].split(',')
    if @organization
      ContactAssignment.where(:person_id => ids, :organization_id => @organization.id).destroy_all
    else raise NoOrganizationError
    end
    render :json => '[]'
  end
end