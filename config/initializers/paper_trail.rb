module PaperTrail
  class Version < ActiveRecord::Base
    include PaperTrail::VersionConcern
    attr_accessible :organization_id, :person_id
  end
end