class OrganizationalRoleSerializer < ActiveModel::Serializer

  attributes :id, :followup_status, :role_id, :start_date, :archive_date,
             :updated_at, :created_at

end

