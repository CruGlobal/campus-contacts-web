class PersonListSerializer < ActiveModel::Serializer

  attributes :id, :first_name, :last_name, :gender, :user_id, :fb_uid, :updated_at, :created_at

end

