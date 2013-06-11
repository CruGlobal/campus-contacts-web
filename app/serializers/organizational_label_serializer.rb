class OrganizationalLabelSerializer < ActiveModel::Serializer

  attributes :id, :person_id, :organization_id, :added_by_id, :label,
             :start_date, :created_at, :updated_at, :removed_date

end

