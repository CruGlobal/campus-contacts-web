class Interaction < ActiveRecord::Base
  attr_accessible :comment, :created_by_id, :updated_by_id, :deleted_at, :interaction_type_id, :organization_id, :privacy_setting, :receiver_id, :timestamp, :created_at, :updated_at

  has_many :interaction_initiators
  has_many :initiators, through: :interaction_initiators, source: :person
  belongs_to :organization
  belongs_to :interaction_type
  belongs_to :receiver, class_name: 'Person', foreign_key: 'receiver_id', touch: true
  belongs_to :creator, class_name: 'Person', foreign_key: 'created_by_id', touch: true

  scope :sorted, order('created_at DESC')
  scope :limited, limit(5)
  after_save :ensure_timestamp

  def destroy
    run_callbacks :destroy do
      self.update_attribute(:updated_at, DateTime.now)
      self.update_attribute(:deleted_at, DateTime.now)
    end
  end

  def delete
    run_callbacks :delete do
      self.update_attribute(:updated_at, DateTime.now)
      self.update_attribute(:deleted_at, DateTime.now)
    end
  end

  def last_updater
    last_updater = Person.find_by_id(updated_by_id)
    last_updater ||= Person.find_by_id(created_by_id)
  end

  def initiator
    self.initiators.first
  end

  def type
    interaction_type.name
  end

  def icon
    return interaction_type.icon
  end

  def privacy
    case privacy_setting
    when 'everyone'
      return "Everyone"
    when 'parents'
      return "Everyone in #{self.organization.parent.name}"
    when 'organization'
      return "Everyone in #{self.organization.name}"
    when 'admins'
      return "Admins in #{self.organization.name}"
    when 'me'
      return "Me only"
    else
      privacy_setting.titleize
    end
  end

  def title
    intiators_string = initiators.collect{|x| "<strong>#{x.name}</strong>" if x.present?}.to_sentence
    creator_string = "<strong>#{creator.name if creator.present?}</strong>"
    receiver_string = "<strong>#{receiver.name if receiver.present?}</strong>"
    case interaction_type.i18n
    when 'comment'
      return "".html_safe
    when 'spiritual_conversation'
      return "#{intiators_string} initiated a spiritual conversation with #{receiver_string}.".html_safe
    when 'gospel_presentation'
      return "#{intiators_string} shared the gospel with #{receiver_string}.".html_safe
    when 'prayed_to_receive_christ'
      return "#{receiver_string} indicated a decision to receive Christ with #{intiators_string}.".html_safe
    when 'holy_spirit_presentation'
      return "#{intiators_string} shared a Holy Spirit presentation with #{receiver_string}.".html_safe
    when 'graduating_on_mission'
      return "#{intiators_string} helped #{receiver_string} develop a plan for graduating on mission.".html_safe
    when 'faculty_on_mission'
      return "#{intiators_string} helped #{receiver_string} develop a plan to be a faculty member on mission.".html_safe
    end
  end

  def to_hash
    @hash = {}
    @hash['id'] = id
    @hash['interaction_type_id'] = interaction_type_id
    @hash['receiver_id'] = receiver_id
    @hash['initiator_ids'] = initiator_ids
    @hash['organization_id'] = organization_id
    @hash['created_by_id'] = created_by_id
    @hash['comment'] = comment
    @hash['privacy_setting'] = privacy_setting
    @hash['timestamp'] = timestamp
    @hash['created_at'] = created_at
    @hash['updated_at'] = updated_at
    @hash['deleted_at'] = deleted_at
    @hash
  end

  def self.get_interactions_hash(person_id, org_id)
    interactions = Interaction.where(receiver_id: person_id, organization_id: org_id).order("created_at DESC")
    interactions.collect(&:to_hash)
  end


  def set_initiators(initiator_ids)
    initiator_ids.uniq.each do |person_id|
      self.interaction_initiators.find_or_create_by_person_id(person_id.to_i)
    end
    # delete removed
    removed_initiators = self.interaction_initiators.where("person_id NOT IN (?)", initiator_ids)
    removed_initiators.delete_all if removed_initiators.present?
    # delete duplicates
    interaction_initiator_ids = self.interaction_initiators.group("person_id").collect(&:id)
    duplicate_initiators = self.interaction_initiators.where("id NOT IN (?)", interaction_initiator_ids)
    duplicate_initiators.delete_all if duplicate_initiators.present?
  end

  private

  def ensure_timestamp
    self.update_attribute(:timestamp, created_at) if timestamp.nil?
  end
end
