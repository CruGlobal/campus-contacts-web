class OrganizationSerializer < ActiveModel::Serializer
  INCLUDES = [:contacts, :admins, :leaders, :people, :surveys, :groups, :keywords]

  attributes :id, :name, :terminology, :ancestry, :show_sub_orgs, :status, :updated_at, :created_at

  has_many *INCLUDES

  def include_associations!
    includes = scope if scope.is_a? Array
    includes = scope[:include] if scope.is_a? Hash
    includes.each do |rel|
      include!(rel.to_sym) if INCLUDES.include?(rel.to_sym)
    end if includes
  end

  INCLUDES.each do |relationship|
    define_method(relationship) do
      add_since(object.send(relationship))
    end
  end

end

