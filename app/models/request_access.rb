class RequestAccess
  include ActiveModel::Model

  attr_accessor :first_name, :last_name, :email, :org_name
  validates :first_name, :last_name, :email, :org_name, presence: true
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates :first_name, :last_name, :org_name, length: { minimum: 2 }

  def save
    ActiveRecord::Base.transaction do
      person = Person.new_from_params(person_params)
      organization = Organization.new(organization_params)

      person.save!
      organization.organizational_permissions.new(person_id: person.id, permission_id: Permission::ADMIN_ID)
      organization.save!
    end
  end

  private

  def person_params
    { first_name: first_name, last_name: last_name, email: email }
  end

  def organization_params
    {
      name: org_name,
      status: 'requested',
      terminology: 'Organization'
    }
  end
end
