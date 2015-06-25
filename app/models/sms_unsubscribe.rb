class SmsUnsubscribe < ActiveRecord::Base
  attr_accessible :phone_number, :organization_id

  belongs_to :organization

  def self.add_to_unsubscribe(phone_number, organization_id)
    self.where(phone_number: phone_number, organization_id: organization_id).first_or_create
  end

  def self.remove_from_unsubscribe(phone_number, organization_id)
    subscribe = self.where(phone_number: phone_number, organization_id: organization_id).first
    subscribe.destroy if subscribe.present?
  end
end
