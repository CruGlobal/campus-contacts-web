class Group < ActiveRecord::Base
  set_table_name 'mh_groups'
  
  has_many :group_labelings, dependent: :destroy
  has_many :group_labels, through: :group_labelings
  has_many :group_memberships, dependent: :destroy
  has_many :involved, through: :group_memberships, source: :involved
  has_many :members, through: :group_memberships, source: :member
  has_many :leaders, through: :group_memberships, source: :leader
  belongs_to :organization
  
  validates_presence_of :name, :location, :meets
  
  def to_s
    name
  end
  
  def public_signup?
    list_publicly? && !approve_join_requests?
  end
end
