class  ActiveModel::Serializer

  def organization_filter(relationship)
    if scope.is_a?(Hash) && organization = scope[:organization]
      object.send(relationship).where(organization_id: organization.id)
    else
      []
    end
  end

  def add_since(rel)
    if scope.is_a?(Hash) && scope[:since].to_i > 0
      rel.where("#{rel.table.name}.updated_at > ?", Time.at(scope[:since].to_i))
    else
      rel
    end
  end

end
