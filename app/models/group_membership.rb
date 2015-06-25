class GroupMembership < ActiveRecord::Base

  belongs_to :group
  belongs_to :person
  belongs_to :leader,
    ->{where('group_memberships.role' => 'leader')}, class_name: 'Person', foreign_key: 'person_id'
  belongs_to :member,
    ->{where('group_memberships.role' => 'member')}, class_name: 'Person', foreign_key: 'person_id'
  belongs_to :involved,
    ->{where('group_memberships.role' => ['leader','member'])}, class_name: 'Person', foreign_key: 'person_id'

  scope :involved,
    ->{where('group_memberships.role' => ['leader','member'])}
  scope :people,
    ->(order){joins(:person).order(order)}
end
