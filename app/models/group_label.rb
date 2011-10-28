class GroupLabel < ActiveRecord::Base
  set_table_name 'mh_group_labels'
  has_many :group_labelings, dependent: :destroy
  belongs_to :organization
  
  def to_s
    name
  end
end
