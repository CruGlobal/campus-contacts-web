class UserSerializer < ActiveModel::Serializer

  attributes :id, :primary_organization_id, :created_at, :updated_at

  def primary_organization_id
    object.person.primary_organization.id
  end

end

