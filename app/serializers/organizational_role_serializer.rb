class OrganizationalRoleSerializer < ActiveModel::Serializer

  attributes :id, :followup_status, :role_id, :role, :start_date, :archive_date,
             :updated_at, :created_at

  def role
    object.role.name
  end
end

