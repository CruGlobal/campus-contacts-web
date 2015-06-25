class GroupLabel < ActiveRecord::Base
  attr_accessible :name, :organization_id, :ancestry, :group_labelings_count

  has_many :group_labelings, dependent: :destroy
  belongs_to :organization

  validates_presence_of :name
  validates_uniqueness_of :name, scope: :organization_id

  def to_s
    name
  end
end
