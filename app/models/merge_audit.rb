class MergeAudit < ActiveRecord::Base
  belongs_to :mergeable, polymorphic: true
  belongs_to :merge_looser, polymorphic: true

  attr_accessible :mergeable, :merge_looser
end
