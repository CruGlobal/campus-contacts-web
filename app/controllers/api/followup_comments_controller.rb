class Api::FollowupCommentsController < ApiController
require 'api_helper'
include ApiHelper
oauth_required :scope => "followup_comments"
before_filter :valid_request_before, :organization_allowed?, :authorized_leader?
skip_before_filter :verify_authenticity_token, :authenticate_user!
rescue_from Exception, :with => :render_json_error

  def create_1
    raise FollowupCommentCreateParamsError unless (params[:rejoicables].present? && params[:followup_comment].present?)
    @followup_comment = FollowupComment.create(params[:followup_comment])
    params[:rejoicables].each do |what|
      if Rejoicable::OPTIONS.include?(what)
        @followup_comment.rejoicables.create(what: what, created_by_id: get_me.id, person_id: @followup_comment.contact_id, organization_id: @followup_comment.organization_id)
      end
    end if params[:rejoicables]
    render :json => "[]"
  end
  
  def show_1
    contact_id = params[:id].present? ? params[:id] : 0
    org = get_organization
    @followup_comments = FollowupComment.includes(:rejoicables).where(:contact_id => contact_id).where(:organization_id => org.id).order("created_at DESC")
    json_output = @followup_comments.collect {|c| {followup_comment: {comment: c.attributes.slice!('updated_at'), rejoicables: c.rejoicables.collect{|y| y.attributes.slice('id','what')}}}}
    final_output = Rails.env.production? ? json_output.to_json : JSON::pretty_generate(json_output)
    render :json => final_output
  end
end
