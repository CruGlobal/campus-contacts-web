class Interaction < ActiveRecord::Base
  attr_accessible :comment, :created_by_id, :deleted_at, :interaction_type_id, :organization_id, :privacy_setting, :receiver_id, :timestamp, :created_at, :updated_at

  has_many :interaction_initiators
  has_many :initiators, through: :interaction_initiators, source: :person
  belongs_to :organization
  belongs_to :interaction_type
  belongs_to :receiver, class_name: 'Person', foreign_key: 'receiver_id'
  belongs_to :creator, class_name: 'Person', foreign_key: 'created_by_id'
  
end
