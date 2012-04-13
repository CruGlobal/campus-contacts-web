class NameUniquenessValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    if object.class.to_s.underscore == 'organization' && object.parent
      object.errors[attribute] << I18n.t('organizations.add_org.name_not_unique') if object.parent.children.any? {|c| c.name == object.name}
    end
  end
end
