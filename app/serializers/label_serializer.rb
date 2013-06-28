class LabelSerializer < ActiveModel::Serializer

  attributes :id, :organization_id, :name, :i18n, :created_at, :updated_at

end

