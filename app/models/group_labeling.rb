class GroupLabeling < ActiveRecord::Base
  self.table_name = 'mh_group_labelings'
  
  belongs_to :group
  belongs_to :group_label, counter_cache: true
end
