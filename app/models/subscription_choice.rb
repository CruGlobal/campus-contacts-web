class SubscriptionChoice < ActiveRecord::Base
  attr_accessible :subscription_sms_session_id, :organization_id, :value
  validates_presence_of :subscription_sms_session_id, :organization_id, :value

  belongs_to :subscription_sms_session
  belongs_to :organization
end
