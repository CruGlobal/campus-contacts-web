class Api::FollowupCommentsController < ApiController
require 'api_helper'
include ApiHelper
oauth_required scope: "followup_comments"
before_filter :valid_request_before, :organization_allowed?, :authorized_leader?, :get_organization
skip_before_filter :verify_authenticity_token, :authenticate_user!
rescue_from Exception, with: :render_json_error

  def create_1
    begin
      @json = ActiveSupport::JSON.decode(params[:json])
    rescue 
      raise InvalidJSONError
    end
    raise FollowupCommentCreateParamsError unless (!@json['rejoicables'].nil? && @json['followup_comment'].present?)
    
    @followup_comment = FollowupComment.create(@json['followup_comment'])

    Person.find(@followup_comment.contact_id).organization_memberships.where(organization_id: @followup_comment.organization_id).first.update_attributes(followup_status: @json['followup_comment']['status'])
    @json['rejoicables'].each do |what|
      if Rejoicable::OPTIONS.include?(what)
        @followup_comment.rejoicables.create(what: what, created_by_id: get_me.id, person_id: @followup_comment.contact_id, organization_id: @followup_comment.organization_id)
      end
    end if @json['rejoicables']
    render json: "[]"
  end
  
  def show_1
    contact_id = params[:id].present? ? params[:id] : 0
    @followup_comments = FollowupComment.includes(:rejoicables).where(contact_id: contact_id).where(organization_id: @organization.id).order("created_at DESC")
    json_output = @followup_comments.collect {|c| {followup_comment: {comment: c.to_hash, rejoicables: c.rejoicables.collect{|y| y.attributes.slice('id','what')}}}}
    final_output = Rails.env.production? ? json_output.to_json : JSON::pretty_generate(json_output)
    render json: final_output
  end
  
  def destroy_1
    raise FollowupCommentDeleteParamsError unless (params[:id].present? && (is_int?(params[:id]) || params[:id].is_a? Array))
    ids = params[:id].split(',')
    
    comments = FollowupComment.where(id: ids)
    role = get_me.organization_memberships.where(organization_id: @organization.id).collect(&:role)
    
    comments.each_with_index do |comment,i|
      if role[i] == 'leader'
        raise FollowupCommentPermissionsError unless comment.commenter_id == get_me.id
      elsif role[i] == 'admin'
        raise FollowupCommentPermissionsError unless comment.organization_id == @organization.id
      else raise FollowupCommentPermissionsError
      end
    end
    
    comments.destroy_all
    
    render :json => '[]'
  end
end
