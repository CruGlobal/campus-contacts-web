class FollowupCommentsController < ApplicationController
  def create
    @followup_comment = FollowupComment.create(params[:followup_comment])
    params[:rejoicables].each do |what|
      if Rejoicable::OPTIONS.include?(what)
        @followup_comment.rejoicables.create(what: what, created_by_id: current_person.id, person_id: @followup_comment.contact_id, organization_id: @followup_comment.organization_id)
      end
    end
  end
end
