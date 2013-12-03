class LongCode < ActiveRecord::Base
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
end
