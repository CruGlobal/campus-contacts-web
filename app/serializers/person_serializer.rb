class PersonSerializer < ActiveModel::Serializer

  HAS_MANY_SIMPLE = [:addresses, :phone_numbers, :email_addresses, :person_transfers, :assigned_tos, :answer_sheets, :all_organization_and_children, :organizational_labels]
  HAS_MANY_CUSTOM = [:contact_assignments, :interactions, :all_organizational_permissions]
  HAS_MANY = HAS_MANY_SIMPLE + HAS_MANY_CUSTOM;

  HAS_ONE_SIMPLE = [:user, :current_address]
  HAS_ONE_CUSTOM = [:organizational_permission]
  HAS_ONE = HAS_ONE_SIMPLE + HAS_ONE_CUSTOM

  INCLUDES = HAS_MANY + HAS_ONE

  attributes :id, :first_name, :last_name, :gender, :campus, :year_in_school, :major, :minor, :birth_date, :date_became_christian, :graduation_date, :picture, :user_id, :fb_uid, :created_at, :updated_at

  has_many *HAS_MANY
  has_one *HAS_ONE

  def attributes
    hash = super
    backported_attributes(hash)
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

  [:assigned_tos, :organizational_roles, :organizational_labels].each do |relationship|
    define_method(relationship) do
      add_since(organization_filter(relationship))
    end
  end

  [:phone_numbers, :email_addresses, :person_transfers, :user, :answer_sheets, :current_address, :addresses].each do |relationship|
    define_method(relationship) do
      add_since(object.send(relationship))
    end
  end

  def interactions
    add_since(object.filtered_interactions(scope[:user].person, scope[:organization]))
  end


  def contact_assignments
    active_people_ids = scope[:organization].all_people.collect(&:id)
    object.contact_assignments.where(person_id: active_people_ids)
  end

  def all_organizational_permissions
    add_since(object.organizational_permissions)
  end

  def organizational_permission
    organization_filter(:organizational_permissions).first
  end

  ###########################
  ## Backported Attributes ##
  ###########################

  def backported_attributes(hash)
    if scope[:include]
      hash['organizational_roles'] = backported_organizational_roles(scope[:organization].id) if scope[:include].include?('organizational_roles')
      hash['all_organizational_roles'] = backported_organizational_roles if scope[:include].include?('all_organizational_roles')
      hash['followup_comments'] = backported_followup_comments if scope[:include].include?('followup_comments')
      hash['comments_on_me'] = backported_comments_on_me if scope[:include].include?('comments_on_me')
      hash['rejoicables'] = backported_rejoicables if scope[:include].include?('rejoicables')
    end
    hash
  end

  def backported_followup_comments
    followup_comments = []
    object.created_interactions.each do |interaction|
      followup_comments << translate_interaction_to_followup_status(interaction)
    end
    followup_comments
  end

  def backported_comments_on_me
    comments_on_me = []
    object.filtered_interactions(scope[:user].person, scope[:organization]).each do |interaction|
      comments_on_me << translate_interaction_to_followup_status(interaction)
    end
    comments_on_me
  end

  def backported_rejoicables
    rejoicables = []
    interactions = object.filtered_interactions(scope[:user].person, scope[:organization])
    interactions.where(interaction_type_id: InteractionType.old_rejoicable_ids).each do |interaction|
      rejoicables << translate_interaction_to_rejoicable(interaction)
    end
    rejoicables
  end

  def backported_organizational_roles(org_id = nil)
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

  def serialize_organizational_permission(organizational_permission)
    response = {}
    response['id'] = organizational_permission.id
    response['person_id'] = organizational_permission.person_id
    response['permission_id'] = organizational_permission.permission_id
    response['organization_id'] = organizational_permission.organization_id
    response['followup_status'] = organizational_permission.followup_status
    response['created_at'] = organizational_permission.created_at
    response['updated_at'] = organizational_permission.updated_at
    response['archive_date'] = organizational_permission.archive_date
    response
  end

  def translate_interaction_to_rejoicable(interaction)
    rejoicable = {}
    rejoicable['id'] = interaction.id
    rejoicable['person_id'] = interaction.receiver_id
    rejoicable['created_by_id'] = interaction.created_by_id
    rejoicable['organization_id'] = interaction.organization_id
    rejoicable['followup_comment_id'] = interaction.id
    rejoicable['what'] = interaction.interaction_type.i18n
    rejoicable['updated_at'] = interaction.updated_at
    rejoicable['created_at'] = interaction.created_at
    rejoicable['deleted_at'] = interaction.deleted_at
    rejoicable
  end

  def translate_interaction_to_followup_status(interaction)
    followup_comment = {}
    followup_comment['id'] = interaction.id
    followup_comment['contact_id'] = interaction.receiver_id
    followup_comment['commenter_id'] = interaction.created_by_id
    followup_comment['comment'] = interaction.comment
    if interaction.receiver.present?
      followup_comment['status'] = interaction.receiver.organizational_permission_for_org(scope[:organization]).try(:followup_status)
    else
      followup_comment['status'] = ""
    end
    followup_comment['organization_id'] = interaction.organization_id
    followup_comment['updated_at'] = interaction.updated_at
    followup_comment['created_at'] = interaction.created_at
    followup_comment['deleted_at'] = interaction.deleted_at
    followup_comment
  end

end

