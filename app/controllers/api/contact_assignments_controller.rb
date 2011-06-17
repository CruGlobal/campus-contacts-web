class Api::ContactAssignmentsController < ApiController
  require 'api_helper'
  include ApiHelper
  oauth_required :scope => "contact_assignment"
  before_filter :valid_request_before, :organization_allowed?, :authorized_leader?
  skip_before_filter :verify_authenticity_token, :authenticate_user!
  rescue_from Exception, :with => :render_json_error
  
  def create_1
    raise ContactAssignmentCreateParamsError unless ((params[:org_id].present? || params[:org].present?) && params[:id].present? && params[:assign_to].present?)
    if !@organization.empty?
      ids = params[:id].split(',')
      ContactAssignment.where(:person_id => ids, :organization_id => @organization.id).destroy_all
      @assign_to = Person.find(params[:assign_to])
      params[:ids].each do |id|
        ContactAssignment.create!(:person_id => id, :organization_id => @organization.id, :assigned_to_id => @assign_to.id)
      end
    end
    render :json => JSON::pretty_generate('[]')
  end
  
  def destroy_1
    raise ContactAssignmentDeleteParamsError unless ((params[:org_id].present? || params[:org].present?) && params[:id].present?)
    ids = params[:id].split(',')
    ContactAssignment.where(:person_id => ids, :organization_id => @organization.first.id).destroy_all unless @organization.empty?
    render :json => JSON::pretty_generate('[]')
  end
  
  private
  
  def get_organization
    org = params[:org_id].present? ? params[:org_id] : params[:org]
    @organization = Organization.where('id = ?',org)
  end
end