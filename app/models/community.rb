class Community < ActiveRecord::Base
  has_one :school
  has_many :users, :through :user_community_joins
  has_many :user_community_joins

  validates_presence_of :school_id, :name, :fbpage
  validates_uniqueness_of :school_id

  def school_name
    return "None" if school.nil?
    school.name
  end
end
