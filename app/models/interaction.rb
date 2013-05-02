class Interaction < ActiveRecord::Base
  attr_accessible :comment, :created_by_id, :deleted_at, :interaction_type_id, :organization_id, :privacy_setting, :receiver_id, :timestamp
end
