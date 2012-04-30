class NameUniquenessValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    if object.class.to_s.underscore == 'organization' && object.parent_id
      begin
        parent = Organization.find(object.parent_id)
        object.errors[attribute] << I18n.t('organizations.add_org.name_not_unique') if parent.children.any? {|c| c.name == object.name}
      rescue => e
        Rails.logger.info e.inspect
      end
    end
  end
end
