class GroupSerializer < ActiveModel::Serializer

  attributes :id, :name, :location, :meets, :meeting_day, :start_time, :end_time, :organization_id,
             :list_publicly, :approve_join_requests, :created_at, :updated_at

end

