class OrganizationSerializer < ActiveModel::Serializer
  HAS_MANY_SIMPLE = [:contacts, :admins, :users, :leaders, :people, :surveys, :groups, :keywords, :labels]
  HAS_MANY_CUSTOM = [:interaction_types]
  HAS_MANY = HAS_MANY_SIMPLE + HAS_MANY_CUSTOM

  attributes :id, :name, :terminology, :ancestry, :show_sub_orgs, :status, :created_at, :updated_at

  has_many *HAS_MANY

  def attributes
    hash = super
    hash['token'] = object.api_client.secret if object.api_client
    hash
  end

  def interaction_types
    add_since(object.interaction_types.where.not(i18n: "faculty_on_mission"))
  end

  def include_associations!
    includes = scope if scope.is_a? Array
    includes = scope[:include] if scope.is_a? Hash
    includes.each do |rel|
      include!(rel.to_sym) if HAS_MANY.include?(rel.to_sym)
    end if includes
  end

  HAS_MANY_SIMPLE.each do |relationship|
    next if relationship == :leaders
    define_method(relationship) do
      add_since(object.send(relationship))
    end
  end

  def leaders
    add_since(object.send(:users))
  end

end

