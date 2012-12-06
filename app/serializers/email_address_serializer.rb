class EmailAddressSerializer < ActiveModel::Serializer

  attributes :id, :email, :person_id, :primary, :created_at, :updated_at

end

