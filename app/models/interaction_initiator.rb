class InteractionInitiator < ActiveRecord::Base
  attr_accessible :interaction_id, :person_id

  belongs_to :interaction
  belongs_to :person

  validates :interaction_id, :person_id, presence: true
end
