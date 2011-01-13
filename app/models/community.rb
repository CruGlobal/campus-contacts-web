class Community < ActiveRecord::Base
  has_one :school
  has_many :persons, :through  => :community_memberships
  has_many :community_memberships

  validates_presence_of :school_id, :name, :fbpage
  validates_uniqueness_of :school_id

  def school_name
    return "None" if school.nil?
    school.name
  end
end
