class MovementIndicatorSuggestion < ActiveRecord::Base
  belongs_to :person
  belongs_to :organization
  belongs_to :label
  attr_accessible :accepted, :reason, :person_id, :label_id, :action

  scope :active, -> { where(accepted: nil) }
  scope :declined, -> { where(accepted: false) }

  before_save :check_action

  def self.fetch_active(org)
    create_new_suggestions(org)
    org.movement_indicator_suggestions.active.includes(:label, :person).order(:label_id, 'people.last_name', 'people.first_name')
  end

  def self.fetch_declined(org)
    org.movement_indicator_suggestions.declined.includes(:label, :person).order(:label_id)
  end

  private

  def self.create_new_suggestions(org)
    since = org.last_indicator_suggestion_at ? org.last_indicator_suggestion_at : org.created_at
    disqualifying_interaction_types = InteractionType.where(i18n: ['graduating_on_mission', 'faculty_on_mission']).pluck(:id)

    org.people.non_staff.where("people.updated_at > ?", since).find_each do |person|

      # Create 'add' suggestions
      unless person.has_interaction_in_org?(disqualifying_interaction_types, org)
        check_for_leader(person, org)
        check_for_disciple(person, org)
        check_for_involved(person, org)
      end

      # Create 'remove' suggestions
      #if person.has_interaction_in_org?(disqualifying_interaction_types, org)
        #[Label.leader, Label.engaged_disciple, Label.involved].each do |label|
          #check_for_remove(person, org, label)
        #end
      #end

    end
    org.update_attributes(last_indicator_suggestion_at: Time.now)
  end

  def self.check_for_leader(person, org)
    unless person.labeled_in_org?(Label.leader, org) ||
           org.movement_indicator_suggestions.where(person_id: person.id, label_id: Label.leader.id, action: 'add').present?
      reason =  case
                when person.group_memberships.where(group_id: org.groups.pluck(:id), role: 'leader').present?
                  'group_leader'
                end

      if reason
        org.movement_indicator_suggestions.create(person_id: person.id,
                                          label_id: Label.leader.id,
                                          reason: reason,
                                          action: 'add')

        # delete the inverse
        #org.movement_indicator_suggestions.where(person_id: person.id, label_id: Label.leader.id, action: 'remove').first.try(:destroy)
      end
    end
  end

  def self.check_for_disciple(person, org)
    unless person.labeled_in_org?(Label.engaged_disciple, org) ||
           org.movement_indicator_suggestions.where(person_id: person.id, label_id: Label.engaged_disciple.id, action: 'add').present?
      reason =  case
                when person.labeled_in_org?(Label.leader, org)
                  'leader'
                when person.created_interactions.includes(:interaction_type)
                                                .where('interactions.organization_id' => org.id,
                                                       'interaction_types.i18n' => 'gospel_presentation')
                                                .where("interactions.created_at > ?", 1.year.ago)
                                                .present?
                  'gospel_presentation'

                when person.created_interactions.includes(:interaction_type)
                                                .where('interactions.organization_id' => org.id,
                                                       'interaction_types.i18n' => 'spiritual_conversation')
                                                .where("interactions.created_at > ?", 1.year.ago)
                                                .present?
                  'spiritual_conversation'
                end

      if reason
        org.movement_indicator_suggestions.create(person_id: person.id,
                                          label_id: Label.engaged_disciple.id,
                                          reason: reason,
                                          action: 'add')

        # delete the inverse
        #org.movement_indicator_suggestions.where(person_id: person.id, label_id: Label.engaged_disciple.id, action: 'remove').first.try(:destroy)
      end
    end
  end

  def self.check_for_involved(person, org)
    disqualifying_interaction_types = InteractionType.where(i18n: ['graduating_on_mission', 'faculty_on_mission']).pluck(:id)
    unless person.labeled_in_org?(Label.involved, org) ||
           person.has_interaction_in_org?(disqualifying_interaction_types, org) ||
           org.movement_indicator_suggestions.where(person_id: person.id, label_id: Label.involved.id, action: 'add').present?
      reason =  case
                when person.group_memberships.where(group_id: org.groups.pluck(:id)).present?
                  'group_membership'
                when person.labeled_in_org?(Label.engaged_disciple, org)
                  'engaged_disciple'
                when person.labeled_in_org?(Label.leader, org)
                  'leader'
                end

      if reason
        org.movement_indicator_suggestions.create(person_id: person.id,
                                          label_id: Label.involved.id,
                                          reason: reason,
                                          action: 'add')

        # delete the inverse
        #org.movement_indicator_suggestions.where(person_id: person.id, label_id: Label.involved.id, action: 'remove').first.try(:destroy)
      end
    end
  end

  #def self.check_for_remove(person, org, label)
    #reason = I18n.t('movement_indicator_suggestions.reasons.graduated')

    #if person.labeled_in_org?(label, org) &&
       #!org.movement_indicator_suggestions.where(person_id: person.id, label_id: Label.involved.id, action: 'remove', accepted: false).present?

      #org.movement_indicator_suggestions.create(person_id: person.id,
                                        #label_id: label.id,
                                        #reason: reason,
                                        #action: 'remove')

    #end

    ## delete the inverse
    #org.movement_indicator_suggestions.where(person_id: person.id, label_id: label, action: 'add').first.try(:destroy)
  #end

  def check_action
    if changed.include?('accepted') && accepted?
      if action == 'add'
        person.organizational_labels.create!(organization_id: organization_id, label_id: label_id)
      #else
        #person.organizational_labels.where(organization_id: organization_id, label_id: label_id).first.try(:destroy)
      end
    end
    true
  end

end
