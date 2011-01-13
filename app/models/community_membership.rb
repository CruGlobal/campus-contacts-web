class CommunityMembership < ActiveRecord::Base
validates_presence_of :community_id, :person_id
validates_uniqueness_of :community_id, :scope => :person_id
belongs_to :person
belongs_to :community
end
