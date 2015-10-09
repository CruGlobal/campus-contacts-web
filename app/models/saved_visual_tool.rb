class SavedVisualTool < ActiveRecord::Base
  belongs_to :person
  belongs_to :organization
  attr_accessible :group, :movement_ids, :name, :organization_id

  serialize :movement_ids, Array
  serialize :more_info, Hash
end
