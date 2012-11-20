class FollowupCommentSerializer < ActiveModel::Serializer

  attributes :id, :contact_id, :commenter_id, :comment, :status,
             :updated_at, :created_at, :deleted_at

end

