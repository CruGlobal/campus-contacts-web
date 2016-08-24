class RequestAccess
  include ActiveModel::Model

  attr_accessor :first_name, :last_name, :email, :org_name
  validates :first_name, :last_name, :email, :org_name, presence: true
  validate :reserved_names
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

  def reserved_names
    return unless org_name.present?
    basic_name = org_name.downcase.split(' at ')[0].strip
    reserved_names = {
      'Cru': ['cru', 'campus crusade', 'campus crusade for christ', 'ccc'],
      'Bridges': ['bridges'],
      'Power to Change': ['power to change', 'power 2 change', 'power2change', 'p2c'],
      'Athletes in Action': ['athletes in action', 'aia']
    }
    reserved_names.each do |name, options|
      next unless options.include? basic_name
      errors.add(:org_name, "Many of #{name}'s ministries already exist in MissionHub. Ask one of "\
                            "your leaders at #{name} to send you an invite.")
      break
    end
  end
end
