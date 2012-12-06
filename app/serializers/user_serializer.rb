class UserSerializer < ActiveModel::Serializer

  attributes :id, :username, :locale, :primary_organization_id, :time_zone, :created_at, :updated_at

end

