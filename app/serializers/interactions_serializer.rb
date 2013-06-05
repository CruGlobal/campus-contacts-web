class InteractionSerializer < ActiveModel::Serializer

  attributes :id, :interaction_type_id, :receiver_id, :initiator_ids, :organization_id, :created_by_id
             :comment, :privacy_setting, :timestamp, :created_at, :updated_at, :deleted_at

end