class MovementIndicatorSuggestion < ActiveRecord::Base
  belongs_to :person
  belongs_to :organization
  belongs_to :label
  attr_accessible :accepted, :reason, :person_id, :label_id, :action

  scope :active, -> { where(accepted: nil) }
  scope :declined, -> { where(accepted: false) }

  def suggestion
    I18n.t("movement_indicator_suggestions.suggestion_html", name: person, label: I18n.t("labels.#{label.i18n}"))
  end

  def self.fetch_active(org)
    create_new_suggestions(org)
    org.movement_indicator_suggestions.active.includes(:label, :person)
  end

  def self.fetch_declined(org)

  end

  private

  def self.create_new_suggestions(org)
    since = org.last_indicator_suggestion_at ? org.last_indicator_suggestion_at : org.created_at
    org.people.where("people.updated_at > ?", since).find_each do |person|
      disqualifying_interaction_types = InteractionType.where(i18n: ['graduating_on_mission', 'faculty_on_mission']).pluck(:id)
      unless person.has_interaction_in_org?(disqualifying_interaction_types, org)
        check_for_leader(person, org)
        check_for_disciple(person, org)
        check_for_involved(person, org)
      end
    end
    org.update_attributes(last_indicator_suggestion_at: Time.now)
  end

  def self.check_for_leader(person, org)
    unless person.labeled_in_org?(Label.leader, org) ||
           org.movement_indicator_suggestions.where(person_id: person.id, label_id: Label.leader.id, action: 'add').present?
      qualifying_interaction_types = InteractionType.where(i18n: ['spiritual_conversation', 'gospel_presentation','prayed_to_receive_christ']).pluck(:id)
      reason =  case
                when person.group_memberships.where(group_id: org.groups.pluck(:id), role: 'leader').present?
                  I18n.t('movement_indicator_suggestions.reasons.group_leader')
                end

      if reason
        org.movement_indicator_suggestions.create(person_id: person.id,
                                          label_id: Label.leader.id,
                                          reason: reason,
                                          action: 'add')

        # delete the inverse
        org.movement_indicator_suggestions.where(person_id: person.id, label_id: Label.leader.id, action: 'remove').first.try(:destroy)
      end
    end
  end

  def self.check_for_disciple(person, org)
    unless person.labeled_in_org?(Label.engaged_disciple, org) ||
           org.movement_indicator_suggestions.where(person_id: person.id, label_id: Label.engaged_disciple.id, action: 'add').present?
      qualifying_interaction_types = InteractionType.where(i18n: ['spiritual_conversation', 'gospel_presentation','prayed_to_receive_christ']).pluck(:id)
      reason =  case
                when person.labeled_in_org?(Label.leader, org)
                  I18n.t('movement_indicator_suggestions.reasons.leader')
                when person.created_interactions.where(organization_id: org.id, interaction_type_id: qualifying_interaction_types)
                  I18n.t('movement_indicator_suggestions.reasons.spiritual_conversation')
                end

      if reason
        org.movement_indicator_suggestions.create(person_id: person.id,
                                          label_id: Label.engaged_disciple.id,
                                          reason: reason,
                                          action: 'add')

        # delete the inverse
        org.movement_indicator_suggestions.where(person_id: person.id, label_id: Label.engaged_disciple.id, action: 'remove').first.try(:destroy)
      end
    end
  end

  def self.check_for_involved(person, org)
    disqualifying_interaction_types = InteractionType.where(i18n: ['graduating_on_mission', 'faculty_on_mission']).pluck(:id)
    unless person.labeled_in_org?(Label.involved, org) ||
           person.has_interaction_in_org?(disqualifying_interaction_types, org) ||
           org.movement_indicator_suggestions.where(person_id: person.id, label_id: Label.involved.id, action: 'add').present?
      reason =  case
                when person.labeled_in_org?(Label.leader, org)
                  I18n.t('movement_indicator_suggestions.reasons.leader')
                when person.group_memberships.where(group_id: org.groups.pluck(:id)).present?
                  I18n.t('movement_indicator_suggestions.reasons.group_membership')
                when person.labeled_in_org?(Label.engaged_disciple, org)
                  I18n.t('movement_indicator_suggestions.reasons.engaged_disciple')
                end

      if reason
        org.movement_indicator_suggestions.create(person_id: person.id,
                                          label_id: Label.involved.id,
                                          reason: reason,
                                          action: 'add')

        # delete the inverse
        org.movement_indicator_suggestions.where(person_id: person.id, label_id: Label.involved.id, action: 'remove').first.try(:destroy)
      end
    end
  end

end
