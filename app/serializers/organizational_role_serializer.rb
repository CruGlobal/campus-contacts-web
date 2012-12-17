class OrganizationalRoleSerializer < ActiveModel::Serializer

  attributes :id, :person_id, :organization_id, :role_id, :followup_status,
             :start_date, :created_at, :updated_at, :archive_date

end

