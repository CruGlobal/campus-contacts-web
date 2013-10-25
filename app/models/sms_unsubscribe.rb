class SmsUnsubscribe < ActiveRecord::Base
  belongs_to :organization

  def self.add_to_unsubscribe(phone_number, organization_id)
    self.find_or_create_by_phone_number_and_organization_id(phone_number, organization_id)
  end

  def self.remove_to_unsubscribe(phone_number, organization_id)
    self.find_or_create_by_phone_number_and_organization_id(phone_number, organization_id).destroy
  end
end
