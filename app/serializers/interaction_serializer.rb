class InteractionSerializer < ActiveModel::Serializer

  HAS_MANY = [:initiators]
  HAS_ONE = [:interaction_type]
  INCLUDES = HAS_MANY + HAS_ONE

  attributes :id, :interaction_type_id, :receiver_id, :initiator_ids, :organization_id, :created_by_id, :comment, :privacy_setting, :timestamp, :created_at, :updated_at, :deleted_at

  has_many *HAS_MANY
  has_one *HAS_ONE

  def include_associations!
   includes = scope if scope.is_a? Array
   includes = scope[:include] if scope.is_a? Hash
   includes.each do |rel|
     if INCLUDES.include?(rel.to_sym)
       include!(rel.to_sym)
     end
   end if includes
  end

  [:initiators, :receiver, :creator].each do |relationship|
    define_method(relationship) do
      add_since(object.send(relationship))
    end
  end

end