class OrganizationalGoal < ActiveRecord::Base
  belongs_to :organization

  validates_presence_of :start_value, :start_date, :end_value, :end_date, :organization_id, :criteria
  validates_numericality_of :start_value, :end_value
  validates_uniqueness_of :criteria, scope: :organization_id
end