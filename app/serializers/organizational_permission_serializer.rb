class OrganizationalPermissionSerializer < ActiveModel::Serializer

  attributes :id, :person_id, :permission_id, :organization_id, :followup_status,
             :start_date, :created_at, :updated_at, :archive_date

  HAS_ONE = [:permission]

  has_one *HAS_ONE

  def include_associations!
    includes = scope if scope.is_a? Array
    includes = scope[:include] if scope.is_a? Hash
    includes.each do |rel|
      if HAS_ONE.include?(rel.to_sym)
        include!(rel.to_sym)
      end
    end if includes
  end

  def permission
    object.permission
  end

end

