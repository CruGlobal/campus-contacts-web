module V4
  class BulkMessage < ActiveRecord::Base
    belongs_to :organization
    belongs_to :sender, class_name: 'Person'
  end
end
