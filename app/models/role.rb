class Role < ActiveRecord::Base
  scope :default, where(organization_id: 0)
end
