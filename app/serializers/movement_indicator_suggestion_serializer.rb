class MovementIndicatorSuggestionSerializer < ActiveModel::Serializer
  attributes :id, :accepted, :reason
  has_one :person
  has_one :organization
  has_one :label
end
