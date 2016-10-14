class MinistryReport
  def initialize(start_date, end_date, parent_org = nil)
    @start_date = start_date
    @end_date = end_date
    @parent_org = parent_org
  end

  def status_changed_count
    conditions = {
      followup_status: %w(attempted_contact contacted do_not_contact completed),
      versions: { event: 'update', created_at: @start_date..@end_date }
    }
    changed_permissions = OrganizationalPermission.includes(:real_versions)
                          .where(conditions)
                          .where("versions.object REGEXP 'followup_status: (uncontacted)?\n'")
    if @parent_org
      changed_permissions = changed_permissions.includes(:organization).where(parent_conditions)
    end
    changed_permissions.count
  end

  def interaction_counts(all_core = true)
    interactions = Interaction.where(timestamp: @start_date..@end_date).where.not(interaction_type_id: InteractionType::COMMENT)
    if @parent_org
      interactions = interactions.includes(:organization).where(parent_conditions).references(:organizations)
    end
    interaction_counts = interactions.group(:interaction_type_id).count
    receiver_counts = receiver_sum_counts(interactions)
    combine_interaction_counts(interaction_counts, receiver_counts, initiator_counts, all_core)
  end

  def receiver_sum_counts(interactions)
    named = interactions.group(:interaction_type_id).distinct.count(:receiver_id)
    nils = interactions.where(receiver_id: nil).group(:interaction_type_id).count
    named.merge(nils) { |_k, a_value, b_value| a_value + b_value }
  end

  def initiator_counts
    initiators = InteractionInitiator.includes(:interaction)
                 .where(interactions: { timestamp: @start_date..@end_date })
                 .where.not(interactions: { interaction_type_id: 1 })
    if @parent_org
      initiators = initiators.includes(interaction: [:organization]).where(parent_conditions)
    end
    initiators.group('interactions.interaction_type_id').distinct.count('interaction_initiators.person_id')
  end

  def new_contacts
    contacts = OrganizationalPermission.where(created_at: @start_date..@end_date)
    if @parent_org
      contacts = contacts.includes(:organization).where(parent_conditions)
    end
    contacts.distinct.count(:person_id)
  end

  def number_of_people_with_label(labels)
    org_labels = OrganizationalLabel
                 .joins('LEFT JOIN organizational_permissions ON '\
                        'organizational_labels.organization_id = organizational_permissions.organization_id AND '\
                        'organizational_labels.person_id = organizational_permissions.person_id')
                 .references(:organizational_permission)
                 .where(removed_date: nil, label: labels,
                        organizational_permissions: { archive_date: nil, deleted_at: nil })
    if @parent_org
      org_labels = org_labels.includes(:organization).where(parent_conditions)
    end
    counts = org_labels.group(:label_id).distinct.count(:person_id)
    counts.transform_keys { |key| Label.find(key).name }
  end

  def gained_label(labels)
    OrganizationalLabel
      .where(label: labels, created_at: @start_date..@end_date)
      .group(:label_id)
      .distinct
      .count(:person_id)
      .transform_keys { |key| Label.find(key).name }
  end

  private

  def combine_interaction_counts(total, receiver, initiators, all_core)
    combined = {}
    type_ids = all_core ? InteractionType::CORE_INTERACTIONS : total.keys
    types = InteractionType.where(id: type_ids)
    types.each do |type|
      name = type.name
      combined[name] = {
        total: total[type.id] || 0,
        receivers: receiver[type.id] || 0,
        initiators: initiators[type.id] || 0
      }
    end
    combined
  end

  def parent_conditions
    parent_org = @parent_org.is_a?(Organization) ? @parent_org : Organization.find(@parent_org)
    parent_ancestry = [parent_org.ancestry, parent_org.id].compact.join('/')
    ['organizations.ancestry like ? OR organizations.ancestry = ? OR organizations.id = ?',
     "#{parent_ancestry}/%", parent_ancestry, parent_org.id]
  end
end
