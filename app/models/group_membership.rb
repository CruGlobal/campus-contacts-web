class GroupMembership < ActiveRecord::Base
  
  belongs_to :group
  belongs_to :person
  belongs_to :leader, conditions: {'group_memberships.permission' => 'leader'}, class_name: 'Person', foreign_key: 'person_id'
  belongs_to :member, conditions: {'group_memberships.permission' => 'member'}, class_name: 'Person', foreign_key: 'person_id'
  belongs_to :involved, conditions: {'group_memberships.permission' => ['leader','member']}, class_name: 'Person', foreign_key: 'person_id'
  
  scope :involved, conditions: {'group_memberships.permission' => ['leader','member']}
  scope :people,  lambda { |order| {
    :joins => :person,
    :order => order
  } }
end
