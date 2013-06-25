class PersonSerializer < ActiveModel::Serializer
  HAS_MANY = [:phone_numbers, :email_addresses, :person_transfers, :contact_assignments, :assigned_tos, :followup_comments, :comments_on_me, :rejoicables, :answer_sheets, :all_organizational_permissions, :all_organization_and_children, :interactions, :organizational_labels, :roles, :organizational_roles, :all_organizational_roles]

  HAS_ONE = [:user, :current_address, :organizational_permission]

  INCLUDES = HAS_MANY + HAS_ONE

  attributes :id, :first_name, :last_name, :gender, :campus, :year_in_school, :major, :minor, :birth_date, :date_became_christian, :graduation_date, :picture, :user_id, :fb_uid, :created_at, :updated_at

  has_many *HAS_MANY
  has_one *HAS_ONE

  def include_associations!
    includes = scope if scope.is_a? Array
    includes = scope[:include] if scope.is_a? Hash
    includes.each do |rel|
      if INCLUDES.include?(rel.to_sym)
        include!(rel.to_sym)
      end
    end if includes
  end

  [:contact_assignments, :assigned_tos, :followup_comments, :comments_on_me, :labels, :rejoicables, :interactions, :organizational_labels, :organizational_permissions].each do |relationship|
    define_method(relationship) do
      add_since(organization_filter(relationship))
    end
  end

  [:phone_numbers, :email_addresses, :person_transfers, :user, :answer_sheets, :current_address].each do |relationship|
    define_method(relationship) do
      add_since(object.send(relationship))
    end
  end

  def organizational_permission
    if scope[:user] && scope[:user] == object.user
      object.organizational_permissions.first
    else
      []
    end
  end

  def roles
    if scope[:user] && scope[:user] == object.user
      add_since(object.roles_for_org_id(scope[:organization].id))
    else
      []
    end
  end

  def organizational_roles
    if scope[:user] && scope[:user] == object.user
      add_since(object.organizational_roles_for_org_id(scope[:organization].id))
    else
      []
    end
  end

  def all_organizational_roles
    if scope[:user] && scope[:user] == object.user
      add_since(object.all_organizational_roles)
    else
      []
    end
  end

  def all_organizational_permissions
    if scope[:user] && scope[:user] == object.user
      add_since(object.organizational_permissions)
    else
      []
    end
  end

end

