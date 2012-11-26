class RejoicableSerializer < ActiveModel::Serializer

  attributes :id, :created_by_id, :followup_comment_id, :what,
             :updated_at, :created_at, :deleted_at

end

