class RequestAccess
  include ActiveModel::Model

  attr_accessor :first_name, :last_name, :email, :org_name
  validates :first_name, :last_name, :email, :org_name, presence: true
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates :first_name, :last_name, :org_name, length: { minimum: 2 }

  def person_params
    { first_name: first_name, last_name: last_name, email_address: email }
  end

  def organization_params
    { name: org_name }
  end
end
