class GroupMembership < ActiveRecord::Base
  set_table_name 'mh_group_memberships'
  
  belongs_to :group
  belongs_to :person
  belongs_to :leader, conditions: {'mh_group_memberships.role' => 'leader'}, class_name: 'Person', foreign_key: 'person_id'
  belongs_to :member, conditions: {'mh_group_memberships.role' => 'member'}, class_name: 'Person', foreign_key: 'person_id'
  belongs_to :involved, conditions: {'mh_group_memberships.role' => ['leader','member']}, class_name: 'Person', foreign_key: 'person_id'
  
  scope :involved, conditions: {'mh_group_memberships.role' => ['leader','member']}
end
