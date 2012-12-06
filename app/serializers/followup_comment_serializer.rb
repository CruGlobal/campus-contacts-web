class FollowupCommentSerializer < ActiveModel::Serializer

  attributes :id, :contact_id, :commenter_id, :comment, :status, :organization_id,
             :created_at, :updated_at, :deleted_at

end

