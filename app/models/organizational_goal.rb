class OrganizationalGoal < ActiveRecord::Base
  belongs_to :organization

  validate :date_check
  validates_presence_of :start_value, :start_date, :end_value, :end_date, :organization_id, :criteria
  validates_numericality_of :start_value, :end_value
  validates_uniqueness_of :criteria, scope: :organization_id

  def date_check
    if start_date >= end_date
      errors.add(:start_date, "must be before End date")
    end
  end
end