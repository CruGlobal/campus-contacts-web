class SubscriptionChoice < ActiveRecord::Base
  belongs_to :subscription_sms_session
  belongs_to :organization
end
