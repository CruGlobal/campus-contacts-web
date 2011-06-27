class Team < ActiveRecord::Base
  belongs_to :organization
  has_many :team_memberships
  has_many :people, through: :team_memberships
  
  validates_presence_of :name, :organization_id
end
