class ContactAssignmentSerializer < ActiveModel::Serializer

  INCLUDES = [:assigned_to, :person]

  attributes :id, :assigned_to_id, :person_id, :organization_id, :created_at, :updated_at, :deleted_at

  has_one *INCLUDES

  def include_associations!
    includes = scope if scope.is_a? Array
    includes = scope[:include] if scope.is_a? Hash
    includes.each do |rel|
      if INCLUDES.include?(rel.to_sym)
        include!(rel.to_sym)
      end
    end if includes
  end
  
  def include_deleted_at?
    scope[:deleted]
  end

  INCLUDES.each do |relationship|
    define_method(relationship) do
      add_since(object.send(relationship))
    end
  end

end

