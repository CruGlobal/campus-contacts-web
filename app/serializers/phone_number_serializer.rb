class PhoneNumberSerializer < ActiveModel::Serializer

  attributes :id, :person_id, :number, :location, :primary, :txt_to_email, :email_updated_at, :created_at, :updated_at, :opted_out

  def opted_out
    object.inactive_from_orgs
  end

end

