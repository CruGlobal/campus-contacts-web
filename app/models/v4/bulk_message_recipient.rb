module V4
  class BulkMessageRecipient < ActiveRecord::Base
    belongs_to :bulk_message, class_name: 'V4::BulkMessage'
    belongs_to :recipient, class_name: 'Person'

    delegate :organization, :sender, to: :bulk_message
  end
end
