class SavedContactSearch < ActiveRecord::Base
  attr_accessible :name, :full_path, :user_id, :organization_id
  belongs_to :user
end
