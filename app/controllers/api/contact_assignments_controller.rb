class Api::ContactAssignmentsController < ApiController
  require 'api_helper'
  include ApiHelper
  oauth_required
  before_filter :get_organization
  skip_before_filter :verify_authenticity_token
  skip_before_filter :authenticate_user!

  def create_1
    json_render = {:error => "You did not provide the appropriate parameters to create a contact assignment."}
    if ((params[:org_id].present? || params[:org].present?) && params[:id].present? && !@organization.empty? && params[:assign_to].present?)
      ids = params[:id].split(',')
      ContactAssignment.where(:person_id => ids, :organization_id => @organization.id).destroy_all
      if params[:assign_to].present?
        @assign_to = Person.find(params[:assign_to])
        params[:ids].each do |id|
          ContactAssignment.create!(:person_id => id, :organization_id => @organization.id, :assigned_to_id => @assign_to.id)
          json_render = []
        end
      end
    end
    render :json => JSON::pretty_generate(json_render)
  end
  
  def destroy_1
    valid_fields = valid_request_with_rescue(request)
    return render :json => valid_fields if valid_fields.is_a? Hash
    return render :json => {:error => "You do not have the appropriate organization memberships to view this data."} unless organization_allowed?
    json_render = {:error => "You did not provide the appropriate parameters to delete a contact assignment."}
    
    ids = params[:id].split(',')
    
    if ((params[:org_id].present? || params[:org].present?) && params[:id].present? && !@organization.empty?)
      ContactAssignment.where(:person_id => ids, :organization_id => @organization.first.id).destroy_all
      json_render = []
    end
    render :json => JSON::pretty_generate(json_render)
  end
  
  def get_organization
    org = params[:org_id].present? ? params[:org_id] : params[:org]
    @organization = Organization.where('id = ?',org)
  end
end