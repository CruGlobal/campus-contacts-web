class PersonSerializer < ActiveModel::Serializer

  attributes :id, :first_name, :last_name, :gender, :campus, :year_in_school, :major, :minor, :birth_date,
             :date_became_christian, :graduation_date, :user_id, :fb_uid, :updated_at, :created_at

  has_many :phone_numbers, :email_addresses, :person_transfers, :contact_assignments,
           :followup_comments, :organizational_roles, :rejoicables

  def include_associations!
    includes = scope if scope.is_a? Array
    includes = scope[:include] if scope.is_a? Hash
    includes.each { |rel| include! rel.to_sym } if includes
  end

  def contact_assignments
    if scope.is_a?(Hash) && organization = scope[:organization]
      object.contact_assignments.where(organization_id: organization.id)
    else
      []
    end
  end

  def followup_comments
    if scope.is_a?(Hash) && organization = scope[:organization]
      object.comments_on_me.where(organization_id: organization.id)
    else
      []
    end
  end

  def organizational_roles
    if scope.is_a?(Hash) && organization = scope[:organization]
      object.organizational_roles.where(organization_id: organization.id)
    else
      []
    end
  end

  def rejoicables
    if scope.is_a?(Hash) && organization = scope[:organization]
      object.rejoicables.where(organization_id: organization.id)
    else
      []
    end
  end

end

