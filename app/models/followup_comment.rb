class FollowupComment < ActiveRecord::Base
  include ActionView::Helpers::DateHelper
  belongs_to :contact, class_name: "Person", foreign_key: "contact_id"
  belongs_to :commenter, class_name: "Person", foreign_key: "commenter_id"
  belongs_to :organization
  has_many :rejoicables, inverse_of: :followup_comment, dependent: :destroy
  # accepts_nested_attributes_for :rejoicables, reject_if: proc { |obj| obj.what.blank? }
  after_create :update_followup_status
  
  def to_hash
    hash = {}
    hash['id'] = id
    hash['contact_id'] = contact_id
    commenter = Person.find(commenter_id)
    hash['commenter'] = { id: commenter_id, name: commenter.to_s, picture: commenter.picture } 
    hash['comment'] = comment
    hash['status'] = status
    hash['organization_id'] = organization_id
    hash['created_at'] = created_at.utc.to_s
    hash['created_at_words'] = time_ago_in_words(created_at) + ' ago'
    hash
  end
  
  private
  def update_followup_status
    om = OrganizationalRole.find_or_create_by_person_id_and_organization_id_and_role_id(contact_id, organization_id, Role::CONTACT_ID)
    om.update_attribute(:followup_status, status)
  end
end
