class InteractionTypeSerializer < ActiveModel::Serializer

  attributes :id, :organization_id, :name, :i18n, :icon, :created_at, :updated_at

end