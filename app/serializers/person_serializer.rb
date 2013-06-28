class PersonSerializer < ActiveModel::Serializer
  HAS_MANY = [:phone_numbers, :email_addresses, :person_transfers, :contact_assignments, :assigned_tos, :followup_comments, :comments_on_me, :rejoicables, :answer_sheets, :all_organizational_permissions, :all_organization_and_children, :interactions, :organizational_labels, :roles, :addresses]

  HAS_ONE = [:user, :current_address, :organizational_permission]

  INCLUDES = HAS_MANY + HAS_ONE

  attributes :id, :first_name, :last_name, :gender, :campus, :year_in_school, :major, :minor, :birth_date, :date_became_christian, :graduation_date, :picture, :user_id, :fb_uid, :created_at, :updated_at

  has_many *HAS_MANY
  has_one *HAS_ONE

  def attributes
    hash = super
    hash['organizational_roles'] = custom_organizational_roles(scope[:organization].id) if scope[:include].include?('organizational_roles')
    hash['all_organizational_roles'] = custom_organizational_roles if scope[:include].include?('all_organizational_roles')
    hash
  end

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

  [:phone_numbers, :email_addresses, :person_transfers, :user, :answer_sheets, :current_address, :addresses].each do |relationship|
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

  def all_organizational_permissions
    if scope[:user] && scope[:user] == object.user
      add_since(object.organizational_permissions)
    else
      []
    end
  end

  def custom_organizational_roles(org_id = nil)
    organizational_permissions_array = []
    organizational_labels_array = []
    if org_id.present?
      organizational_permissions = object.organizational_permissions.where(organization_id: org_id)
      organizational_label = object.organizational_labels.where(organization_id: org_id)
    else
      organizational_permissions = object.organizational_permissions
      organizational_label = object.organizational_labels
    end

    organizational_permissions.each do |p|
      organizational_permissions_array << {
        'id' => p.id,
        'followup_status' => p.followup_status || 'uncontacted',
        'role_id' => p.permission_id,
        'start_date' => p.start_date,
        'archive_date' => p.archive_date,
        'updated_at' => p.updated_at,
        'created_at' => p.created_at
      }
    end
    organizational_label.each do |l|
      organizational_labels_array << {
        'id' => l.id,
        'followup_status' => nil,
        'role_id' => l.label_id,
        'start_date' => l.start_date,
        'archive_date' => l.removed_date,
        'updated_at' => l.updated_at,
        'created_at' => l.created_at
      }
    end

    organizational_roles = organizational_permissions_array + organizational_labels_array
    return organizational_roles
  end

end

