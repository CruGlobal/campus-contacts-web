class Group < ActiveRecord::Base
  set_table_name 'mh_groups'
  
  has_many :group_labelings
  has_many :group_labels, through: :group_labelings
  
  validates_presence_of :name, :location, :meets
  
  def to_s
    name
  end
end
