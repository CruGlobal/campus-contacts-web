class GroupLabel < ActiveRecord::Base
  set_table_name 'mh_group_labels'
  belongs_to :organization
  
  def to_s
    name
  end
end
