class GroupLabeling < ActiveRecord::Base
  set_table_name 'mh_group_labelings'
  
  belongs_to :group
  belongs_to :group_label
end
