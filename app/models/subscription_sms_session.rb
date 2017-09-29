class SubscriptionSmsSession < AbstractSmsSession
  attr_accessible :phone_number, :person_id, :interactive, :ended

  validates_presence_of :phone_number, :person_id
end
