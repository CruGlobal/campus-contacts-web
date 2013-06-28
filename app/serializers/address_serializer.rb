class AddressSerializer < ActiveModel::Serializer

  attributes :id, :address1, :address2, :city, :state, :country, :zip, :address_type

end