class Api::FollowupCommentsController < ApplicationController
require 'api_helper'
include ApiHelper
oauth_required :scope => "followup_comments"
before_filter :valid_request_before, :organization_allowed?, :authorized_leader?
skip_before_filter :verify_authenticity_token, :authenticate_user!
rescue_from Exception, :with => :render_json_error

  def create_1
    @followup_comment = FollowupComment.create(params[:followup_comment])
    params[:rejoicables].each do |what|
      if Rejoicable::OPTIONS.include?(what)
        @followup_comment.rejoicables.create(what: what, created_by_id: current_person.id, person_id: @followup_comment.contact_id, organization_id: @followup_comment.organization_id)
      end
    end if params[:rejoicables]
  end
end
