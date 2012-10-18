class GroupLabeling < ActiveRecord::Base
  
  belongs_to :group
  belongs_to :group_label, counter_cache: true
end
