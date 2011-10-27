class GroupMembership < ActiveRecord::Base
  belongs_to :group
  belongs_to :person
  belongs_to :leader, conditions: {'group_memberships.role' => 'leader'}, class_name: 'Person', foreign_key: 'person_id'
  belongs_to :member, conditions: {'group_memberships.role' => 'member'}, class_name: 'Person', foreign_key: 'person_id'
  belongs_to :involved, conditions: {'group_memberships.role' => ['leader','member']}, class_name: 'Person', foreign_key: 'person_id'
  
  scope :involved, conditions: {'group_memberships.role' => ['leader','member']}
end
