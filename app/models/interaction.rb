class Interaction < ActiveRecord::Base
  attr_accessible :comment, :created_by_id, :deleted_at, :interaction_type_id, :organization_id, :privacy_setting, :receiver_id, :timestamp, :created_at, :updated_at

  has_many :interaction_initiators
  has_many :initiators, through: :interaction_initiators, source: :person
  belongs_to :organization
  belongs_to :interaction_type
  belongs_to :receiver, class_name: 'Person', foreign_key: 'receiver_id'
  belongs_to :creator, class_name: 'Person', foreign_key: 'created_by_id'
  
  scope :recent, order('created_at DESC')
  
  def initiator
    self.initiators.first
  end
  
  def icon
    return interaction_type.icon
  end
  
  def title
    case interaction_type.i18n
    when 'comment'
      return "<strong>#{self.initiator}</strong> shared a comment.".html_safe
    when 'spiritual_conversation'
      return "<strong>#{self.initiator}</strong> initiated spiritual conversation with <strong>#{receiver}</strong>.".html_safe
    when 'gospel_presentation'
      return "<strong>#{self.initiator}</strong> shared the gospel with <strong>#{receiver}</strong>.".html_safe
    when 'prayed_to_receive_christ'
      return "<strong>#{self.initiator}</strong> led <strong>#{receiver}</strong> to pray to receive Christ.".html_safe
    when 'holy_spirit_presentation'
      return "<strong>#{self.initiator}</strong> shared the holy spirit presentation with <strong>#{receiver}</strong>.".html_safe
    when 'graduating_on_mission'
      return "<strong>#{self.initiator}</strong> helped <strong>#{receiver}</strong> develop a plan for graduating on a mission.".html_safe
    when 'faculty_on_mission'
      return "<strong>#{self.initiator}</strong> helped <strong>#{receiver}</strong> develop a plan to be a faculty member on a mission.".html_safe
    end
  end
  
end
