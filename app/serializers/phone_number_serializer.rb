class PhoneNumberSerializer < ActiveModel::Serializer

  attributes :id, :number, :location, :primary, :created_at, :updated_at, :txt_to_email, :email_updated_at, :person_id

end

